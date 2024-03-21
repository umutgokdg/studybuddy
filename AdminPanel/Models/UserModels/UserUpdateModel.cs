namespace StudyBuddySAP.Models.UserModels
{
    public class UserUpdateModel
    {
        public string ObjectId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public int Points { get; set; }
        public string Status { get; set; }
        public List<string>? IndividualTasks { get; set; }
    }
}
