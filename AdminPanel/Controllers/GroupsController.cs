using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Linq;
using StudyBuddySAP.Models.GroupModels;
using Group = StudyBuddySAP.DataAccess.Entities.Group;

namespace StudyBuddySAP.Controllers
{
    
    public class GroupsController : BaseController<GroupsController>
    {

        
        public IActionResult Index()
        {

            var model = Context.Groups.AsQueryable().ToList().Select(i => new GroupIndexModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Subject = i.subject,
                Resources = ResourcesForGroup(i.resource_ids),
                CreatedDate = i.created_at,
                CreatedBy = MemberForGroup(i.created_by),
                MemberUsers = MembersForGroup(i.user_ids),
                InvitedUsers = MembersForGroup(i.invited_user_ids),
                Tasks = TasksForGroup(i.task_ids)

            }).ToList();

            return View(model);
        }

        [HttpGet]

        public IActionResult AddGroup()
        {
            var model = new GroupAddModel
            {
                MemberUsers = Context.Users.AsQueryable().ToList().Select(i => i.first_name).ToList(),
            };

            return PartialView("Partial/_GroupEklePartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult AddGroup(GroupAddModel groupAddModel)
        {
            var yeniGroup = new Group
            {

                _id = ObjectId.GenerateNewId(),
                title = groupAddModel.Title,
                subject = groupAddModel.Subject,
                created_at = DateTime.Now,
                created_by = new ObjectId("65959d84740a052426942469"),
                user_ids = UserIdsForGroup(groupAddModel.MemberUsers),
                resource_ids = ResourceIdsForGroup(groupAddModel.Resources),
                task_ids = TaskIdsForGroup(groupAddModel.Tasks),
                invited_user_ids = Array.Empty<ObjectId>(),
                __v = 0,

            };



            Context.Groups.Add(yeniGroup);
            Context.SaveChanges();

            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult UpdateGroup(string id)
        {
            var model = Context.Groups.ToList().Where(i => i._id.ToString() == id).Select(i => new GroupUpdateModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Subject = i.subject,
                Resources = ResourcesForGroup(i.resource_ids),
                CreatedDate = i.created_at,
                CreatedBy = MemberForGroup(i.created_by),
                MemberUsers = MembersForGroup(i.user_ids),
                InvitedUsers = MembersForGroup(i.invited_user_ids),
                Tasks = TasksForGroup(i.task_ids)
            }).FirstOrDefault();
            return PartialView("Partial/_GroupDuzenlePartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult UpdateGroup(GroupUpdateModel groupUpdateModel)
        {
            var model = Context.Groups.FirstOrDefault(i => i._id.ToString() == groupUpdateModel.ObjectId);

            model.title = groupUpdateModel.Title;
            model.subject = groupUpdateModel.Subject;
            model.resource_ids = ResourceIdsForGroup(groupUpdateModel.Resources);
            model.created_by = UserIdForGroup(groupUpdateModel.CreatedBy);
            model.user_ids = UserIdsForGroup(groupUpdateModel.MemberUsers);
            model.invited_user_ids = UserIdsForGroup(groupUpdateModel.InvitedUsers);
            model.task_ids = TaskIdsForGroup(groupUpdateModel.Tasks);
            model.__v++;

            Context.SaveChanges();
            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult DeleteGroup(string id)
        {
            var model = Context.Groups.AsQueryable().ToList().Where(i => i._id.ToString() == id).Select(i => new GroupDeleteModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Subject = i.subject,
                CreatedBy = MemberForGroup(i.created_by),
            }).FirstOrDefault();
            return PartialView("Partial/_GroupSilPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteGroupPost(string ObjectId)
        {
            var groupToDel = Context.Groups.FirstOrDefault(i => i._id.ToString() == ObjectId);

            if (groupToDel != null)
            {
                Context.Groups.Remove(groupToDel);
                Context.SaveChanges();
            }

            return RedirectToAction("Index");
        }



        public List<string> TasksForGroup(ObjectId[] taskId)
        {
            if (taskId == null)
            {
                return null;
            }

            List<string> tasks = new List<string>();

            foreach (var item in taskId)
            {
                var task = Context.Tasks.FirstOrDefault(i => i._id == item);
                if (task != null)
                {
                    tasks.Add(task.title);
                }
            }

            return tasks;

        }
        public ObjectId[] TaskIdsForGroup(List<string> taskIdList)
        {
            if (taskIdList == null || !taskIdList.Any())
            {
                return Array.Empty<ObjectId>();
            }

            var taskIds = new List<ObjectId>();

            foreach (var id in taskIdList)
            {
                var task = Context.Tasks.FirstOrDefault(i => i.title == id);
                if (task != null)
                {
                    taskIds.Add(task._id);
                }
            }

            return taskIds.ToArray();
        }
        public List<string> ResourcesForGroup(ObjectId[] resourceId)
        {
            if (resourceId == null)
            {
                return null;
            }


            List<string> resources = new List<string>();

            foreach (var item in resourceId)
            {
                var resource = Context.Resources.FirstOrDefault(i => i._id == item);
                if (resource != null)
                {

                    resources.Add(resource.title);
                }
            }

            return resources;
        }

        public ObjectId[] ResourceIdsForGroup(List<string> resourceIdList)
        {
            if (resourceIdList == null || !resourceIdList.Any())
            {
                return Array.Empty<ObjectId>();
            }

            var resourceIds = new List<ObjectId>();

            foreach (var id in resourceIdList)
            {
                var resource = Context.Resources.FirstOrDefault(i => i.title == id);
                if (resource != null)
                {
                    resourceIds.Add(resource._id);
                }
            }

            return resourceIds.ToArray();
        }

        public string MemberForGroup(ObjectId userId)
        {
            if (userId == null)
            {
                return null;
            }

            if (Context.Users.FirstOrDefault(i => i._id == userId) != null)
            {

                string name = Context.Users.FirstOrDefault(i => i._id == userId).first_name + " " + Context.Users.FirstOrDefault(i => i._id == userId).last_name;
                return name;
            }
            return null;

        }
        public ObjectId UserIdForGroup(string memberName)
        {

            var userId = Context.Users.FirstOrDefault(i => i.first_name + " " + i.last_name == memberName)._id;

            return userId;

        }

        public List<string> MembersForGroup(ObjectId[] userId)
        {
            if (userId == null)
            {
                return null;
            }


            List<string> members = new List<string>();

            foreach (var item in userId)
            {
                var user = Context.Users.FirstOrDefault(i => i._id == item);

                if (user != null)
                {
                    members.Add(user.first_name + " " + user.last_name);
                }
            }

            return members;
        }

        public ObjectId[] UserIdsForGroup(List<string> memberIds)
        {
            if (memberIds == null || !memberIds.Any())
            {
                return Array.Empty<ObjectId>();
            }

            var userIds = new List<ObjectId>();

            foreach (var id in memberIds)
            {
                var user = Context.Users.FirstOrDefault(i => i.first_name + " " + i.last_name == id);
                if (user != null)
                {
                    userIds.Add(user._id);
                }
            }

            return userIds.ToArray();
        }
        public IActionResult GetResourcesJson(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
            {
                var _query = Context.Resources.AsQueryable().ToList().Select(i => new { id = i._id.ToString(), text = i.title }).ToList();

                var _data = new
                {
                    results = _query,
                    pagination = new { more = false }
                };

                // Serialize the object to JSON

                return Json(_data);
            }
            var query = Context.Resources.AsQueryable().ToList()
                .Where(i => string.IsNullOrEmpty(searchTerm) || (i.title).Contains(searchTerm))
                .Select(i => new { id = i._id.ToString(), text = i.title })
                .ToList();

            var data = new
            {
                results = query,
                pagination = new { more = false }
            };

            // Serialize the object to JSON

            return Json(data);
        }
        public IActionResult GetTasksJson(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
            {
                var _query = Context.Tasks.AsQueryable().ToList().Select(i => new { id = i._id.ToString(), text = i.title }).ToList();

                var _data = new
                {
                    results = _query,
                    pagination = new { more = false }
                };

                // Serialize the object to JSON

                return Json(_data);
            }
            var query = Context.Tasks.AsQueryable().ToList()
                .Where(i => string.IsNullOrEmpty(searchTerm) || (i.title).Contains(searchTerm))
                .Select(i => new { id = i._id.ToString(), text = i.title })
                .ToList();

            var data = new
            {
                results = query,
                pagination = new { more = false }
            };

            // Serialize the object to JSON

            return Json(data);
        }

        public IActionResult GetNamesJson(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
            {
                var _query = Context.Users.AsQueryable().ToList().Select(i => new { id = i._id.ToString(), text = i.first_name + " " + i.last_name }).ToList();

                var _data = new
                {
                    results = _query,
                    pagination = new { more = false }
                };

                // Serialize the object to JSON

                return Json(_data);
            }
            // Filter the users based on the search term
            var query = Context.Users.AsQueryable().ToList()
                .Where(u => string.IsNullOrEmpty(searchTerm) || (u.first_name + " " + u.last_name).Contains(searchTerm))
                .Select(u => new { id = u._id.ToString(), text = u.first_name + " " + u.last_name })
                .ToList();

            var data = new
            {
                results = query,
                pagination = new { more = false }
            };

            // Serialize the object to JSON
            return Json(data);
        }

        public IActionResult GetGroupsJson(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
            {
                var _query = Context.Groups.AsQueryable().ToList().Select(i => new { id = i._id.ToString(), text = i.title }).ToList();

                var _data = new
                {
                    results = _query,
                    pagination = new { more = false }
                };

                // Serialize the object to JSON

                return Json(_data);
            }
            var query = Context.Groups.AsQueryable().ToList()
                .Where(i => string.IsNullOrEmpty(searchTerm) || (i.title).Contains(searchTerm))
                .Select(i => new { id = i._id.ToString(), text = i.title })
                .ToList();

            var data = new
            {
                results = query,
                pagination = new { more = false }
            };

            // Serialize the object to JSON

            return Json(data);
        }
    }
}
