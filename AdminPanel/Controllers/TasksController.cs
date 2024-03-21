using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using StudyBuddySAP.Models.TaskModels;
using Task = StudyBuddySAP.DataAccess.Entities.Task;

namespace StudyBuddySAP.Controllers
{

    public class TasksController : BaseController<TasksController>
    {
        public IActionResult Index()
        {

            var model = Context.Tasks.AsQueryable().ToList().Where(i => i.group_id != null).Select(i => new TaskIndexModel
            {
                ObjectId = i._id.ToString(),
                TaskTitle = i.title,
                TaskDescription = i.description,
                IsCompleted = i.completed,
                CreatedAt = i.created_at,
                CreatedBy = UserNameFromObjectId(i.created_by),
                DueAt = i.due_at,
                UsersAssigned = UsersAssignedForTasks(i.users_assigned),
            }).ToList();

            var nullModel = Context.Tasks.AsQueryable().ToList().Where(i => i.group_id == null).Select(i => new TaskIndexModel
            {
                ObjectId = i._id.ToString(),
                TaskTitle = i.title,
                TaskDescription = i.description,
                IsCompleted = i.completed,
                CreatedAt = i.created_at,
                CreatedBy = UserNameFromObjectId(i.created_by),
                AssignedGroup = GroupNameFromId(i.group_id),
                DueAt = i.due_at,
                UsersAssigned = UsersAssignedForTasks(i.users_assigned),
            }).ToList();

            List<TaskIndexModel> tasks = [.. model, .. nullModel];

            return View(tasks);
        }
        public IActionResult AddTask()
        {
            var model = new TaskAddModel
            {

            };

            return PartialView("Partial/_TaskEklePartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult AddTask(TaskAddModel taskAddModel)
        {
            var yeniResource = new Task
            {
                _id = ObjectId.GenerateNewId(),
                title = taskAddModel.Title,
                description = taskAddModel.Description,
                completed = false,
                created_at = DateTime.Now,
                created_by = new ObjectId("65959d84740a052426942469"),
                due_at = taskAddModel.Due,
                group_id = GroupIdFromGroupName(taskAddModel.Group),
                users_assigned = UserAssignedForTasksByUserIds(taskAddModel.UsersAssigned),
                __v = 0,
            };


            Context.Tasks.Add(yeniResource);
            Context.SaveChanges();

            return RedirectToAction("Index");
        }
        [HttpGet]
        public IActionResult UpdateTask(string id)
        {
            var task = Context.Tasks.ToList().Where(i => i._id.ToString() == id).Select(i => new TaskUpdateModel
            {
                ObjectId = id,
                TaskTitle = i.title,
                TaskDescription = i.description,
                IsCompleted = i.completed,
                CreatedAt = i.created_at,
                CreatedBy = UserNameFromObjectId(i.created_by),
                DueAt = i.due_at,
                UsersAssigned = UsersAssignedForTasks(i.users_assigned),
            }).FirstOrDefault();

            return PartialView("Partial/_TaskDuzenlePartial", task);
        }

        [HttpPost]
        public IActionResult UpdateTask(TaskUpdateModel taskUpdateModel)
        {
            var model = Context.Tasks.FirstOrDefault(i => i._id.ToString() == taskUpdateModel.ObjectId);

            model.title = taskUpdateModel.TaskTitle;
            model.description = taskUpdateModel.TaskDescription;
            model.completed = taskUpdateModel.IsCompleted;
            model.created_by = IdFromUserName(taskUpdateModel.CreatedBy);
            model.due_at = taskUpdateModel.DueAt;
            model.__v++;
            model.users_assigned = UserAssignedForTasksByUserIds(taskUpdateModel.UsersAssigned);

            Context.SaveChanges();
            return RedirectToAction("Index");
        }

        [HttpGet]
        public IActionResult DeleteTask(string id)
        {
            var model = Context.Tasks.AsQueryable().ToList().Where(i => i._id.ToString() == id).Select(i => new TaskDeleteModel
            {
                ObjectId = i._id.ToString(),
                Title = i.title,
                Description = i.description,
                CreatedBy = UserNameFromObjectId(i.created_by),
            }).FirstOrDefault();

            return PartialView("Partial/_TaskSilPartial", model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteTaskPost(string ObjectId)
        {
            var taskToDel = Context.Tasks.FirstOrDefault(i => i._id.ToString() == ObjectId);

            if (taskToDel != null)
            {
                Context.Tasks.Remove(taskToDel);
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

        public string GroupNameFromId(ObjectId? groupId)
        {
            if (groupId == null)
            {
                return null;
            }

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

        public ObjectId[] UserAssignedForTasksByUserIds(List<string> userNames)
        {
            if (userNames == null || !userNames.Any())
            {
                return Array.Empty<ObjectId>();
            }

            var userIds = new List<ObjectId>();

            foreach (var name in userNames)
            {
                var user = Context.Users.FirstOrDefault(i => i.first_name + " " + i.last_name == name);
                if (user != null)
                {
                    userIds.Add(user._id);
                }
            }

            return userIds.ToArray();
        }

        public List<string> UsersAssignedForTasks(ObjectId[] userIds)
        {
            if (userIds == null)
            {
                return new List<string>();
            }


            List<string> members = new List<string>();

            foreach (var item in userIds)
            {
                var user = Context.Users.FirstOrDefault(i => i._id == item);

                if (user != null)
                {
                    members.Add(user.first_name + " " + user.last_name);
                }
            }

            return members;
        }
    }
}
