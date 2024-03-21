using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using StudyBuddySAP.Models.UserModels;


namespace StudyBuddySAP.Controllers
{

    public class UsersController : BaseController<UsersController>
    {
        public IActionResult Index()
        {

            var model = Context.Users.AsQueryable().ToList().Select(i => new UserIndexModel
            {
                ObjectId = i._id.ToString(),
                FirstName = i.first_name,
                LastName = i.last_name,
                Email = i.email,
                Points = i.points,
                Badge = i.badge,
                CreateDate = i.created_at,
                Status = i.status,
                IndividualTasks = TasksForPerson(i.individual_tasks),
            }).ToList();

            return View(model);
        }

        public IActionResult UpdateUser(string id)
        {
            var model = Context.Users.ToList().Where(i => i._id.ToString() == id).Select(i => new UserUpdateModel
            {
                ObjectId = i._id.ToString(),
                FirstName = i.first_name,
                LastName = i.last_name,
                Email = i.email,
                Points = i.points,
                Status = i.status,
                IndividualTasks = TasksForPerson(i.individual_tasks),
            }).FirstOrDefault();

            return PartialView("Partial/_UserDuzenlePartial", model);
        }

        [HttpPost]
        public IActionResult UpdateUser(UserUpdateModel userUpdateModel)
        {
            var model = Context.Users.FirstOrDefault(i => i._id.ToString() == userUpdateModel.ObjectId);

            model.first_name = userUpdateModel.FirstName;
            model.last_name = userUpdateModel.LastName;
            model.email = userUpdateModel.Email;
            model.points = userUpdateModel.Points;
            model.status = userUpdateModel.Status;
            model.__v++;
            model.individual_tasks = TaskIdsForPerson(userUpdateModel.IndividualTasks);

            Context.SaveChanges();

            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult DeleteUser(string id)
        {
            var model = Context.Users.AsQueryable().ToList().Where(i => i._id.ToString() == id).Select(i => new UserDeleteModel
            {
                ObjectId = i._id.ToString(),
                Name = i.first_name + " " + i.last_name,

            }).FirstOrDefault();
            return PartialView("Partial/_UserSilPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteUserPost(string ObjectId)
        {
            var userToDel = Context.Users.FirstOrDefault(i => i._id.ToString() == ObjectId);

            if (userToDel != null)
            {
                Context.Users.Remove(userToDel);
                Context.SaveChanges();
            }

            return RedirectToAction("Index");
        }

        public ObjectId[] TaskIdsForPerson(List<string> tasks)
        {
            if (tasks == null)
            {
                return null;
            }

            var taskIds = new List<ObjectId>();

            foreach (var name in tasks)
            {
                var task = Context.Tasks.FirstOrDefault(i => i.title == name);
                if (task != null)
                {
                    taskIds.Add(task._id);
                }
            }

            return taskIds.ToArray();
        }
        public List<string> TasksForPerson(ObjectId[] taskId)
        {
            if (taskId == null)
            {
                return new List<string>();
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
    }
}
