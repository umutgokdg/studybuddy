using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using StudyBuddySAP.Models.ResourceModels;
using Resource = StudyBuddySAP.DataAccess.Entities.Resource;

namespace StudyBuddySAP.Controllers
{

    public class ResourcesController : BaseController<ResourcesController>
    {
        public IActionResult Index()
        {
            var model = Context.Resources.AsQueryable().ToList().Select(i => new ResourceIndexModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Description = i.description,
                Link = i.link,
                UploadTime = i.uploaded_at,
                UploadedBy = UserNameFromObjectId(i.uploaded_by),
                GroupName = GroupNameFromId(i.group_id)
            });
            return View(model);
        }
        public IActionResult AddResource()
        {
            var model = new ResourceAddModel
            {

            };

            return PartialView("Partial/_ResourceEklePartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult AddResource(ResourceAddModel resourceAddModel)
        {
            var yeniResource = new Resource
            {
                _id = ObjectId.GenerateNewId(),
                title = resourceAddModel.Title,
                description = resourceAddModel.Description,
                link = resourceAddModel.Link,
                uploaded_at = DateTime.Now,
                uploaded_by = new ObjectId("65959d84740a052426942469"),
                group_id = GroupIdFromGroupName(resourceAddModel.Group),
                __v = 0,
            };


            Context.Resources.Add(yeniResource);
            Context.SaveChanges();

            return RedirectToAction("Index");
        }

        public IActionResult UpdateResource(string id)
        {
            var model = Context.Resources.ToList().Where(i => i._id.ToString() == id).Select(i => new ResourceUpdateModel
            {
                ObjectId = id,
                Title = i.title,
                Description = i.description,
                Link = i.link,
                UploadTime = i.uploaded_at,
                UploadedBy = UserNameFromObjectId(i.uploaded_by),
            }).FirstOrDefault();

            return PartialView("Partial/_ResourceDuzenlePartial", model);
        }

        [HttpPost]
        public IActionResult UpdateResource(ResourceUpdateModel resourceUpdateModel)
        {
            var model = Context.Resources.FirstOrDefault(i => i._id.ToString() == resourceUpdateModel.ObjectId);

            model.title = resourceUpdateModel.Title;
            model.description = resourceUpdateModel.Description;
            model.link = resourceUpdateModel.Link;
            model.uploaded_at = resourceUpdateModel.UploadTime;
            model.uploaded_by = IdFromUserName(resourceUpdateModel.UploadedBy);
            model.__v++;

            Context.SaveChanges();
            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult DeleteResource(string id)
        {
            var model = Context.Resources.AsQueryable().ToList().Where(i => i._id.ToString() == id).Select(i => new ResourceDeleteModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Description = i.description,
                CreatedBy = UserNameFromObjectId(i.uploaded_by),
            }).FirstOrDefault();

            return PartialView("Partial/_ResourceSilPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteResourcePost(string ObjectId)
        {
            var groupToDel = Context.Resources.FirstOrDefault(i => i._id.ToString() == ObjectId);

            if (groupToDel != null)
            {
                Context.Resources.Remove(groupToDel);
                Context.SaveChanges();
            }

            return RedirectToAction("Index");
        }

        public string UserNameFromObjectId(ObjectId userId)
        {
            if (Context.Users.FirstOrDefault(i => i._id == userId) == null)
            {
                return null;
            }

            string name = Context.Users.FirstOrDefault(i => i._id == userId).first_name + " " + Context.Users.FirstOrDefault(i => i._id == userId).last_name;

            return name;
        }

        public ObjectId IdFromUserName(string userName)
        {

            var userId = Context.Users.FirstOrDefault(i => i.first_name + " " + i.last_name == userName)._id;

            return userId;
        }

        public string GroupNameFromId(ObjectId groupId)
        {
            if (Context.Groups.FirstOrDefault(i => i._id == groupId) == null)
            {
                return null;
            }

            string groupTitle = Context.Groups.FirstOrDefault(i => i._id == groupId).title;

            return groupTitle;
        }

        public ObjectId GroupIdFromGroupName(string groupTitle)
        {

            var groupId = Context.Groups.FirstOrDefault(i => i.title == groupTitle)._id;

            return groupId;
        }

    }
}
