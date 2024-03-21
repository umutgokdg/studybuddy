namespace StudyBuddySAP.Models.UserModels
{
    public class UserIndexModel
    {

        public string ObjectId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public int Points { get; set; }
        public string Badge { get; set; }
        public DateTime CreateDate { get; set; }
        public string Status { get; set; }
        public List<string>? IndividualTasks { get; set; }


    }
}
