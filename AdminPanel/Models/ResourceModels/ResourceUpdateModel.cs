namespace StudyBuddySAP.Models.ResourceModels
{
    public class ResourceUpdateModel
    {
        public string ObjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Link { get; set; }
        public DateTime UploadTime { get; set; }
        public string UploadedBy { get; set; }
    }
}
