using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace StudyBuddySAP.DataAccess.Entities

{
    [BsonIgnoreExtraElements]
    public class Task

    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId _id { get; set; }
        public string? title { get; set; }
        public string? description { get; set; }
        public bool completed { get; set; }
        public DateTime created_at { get; set; }
        public ObjectId created_by { get; set; }
        public DateTime? due_at { get; set; }
        public ObjectId? group_id { get; set; }
        public ObjectId[] users_assigned { get; set; }
        public int __v { get; set; }
    }
}
