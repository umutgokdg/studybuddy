using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace StudyBuddySAP.DataAccess.Entities

{
    [BsonIgnoreExtraElements]
    public class Resource
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId _id { get; set; }
        public string? title { get; set; }
        public string? description { get; set; }
        public string? link { get; set; }
        public DateTime uploaded_at { get; set; }
        public ObjectId uploaded_by { get; set; }
        public ObjectId group_id { get; set; }
        public int __v { get; set; }

    }

}
