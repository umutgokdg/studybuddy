using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace StudyBuddySAP.DataAccess.Entities

{

    public class Group

    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId _id { get; set; }
        [BsonElement("title", Order = 2)]
        public string title { get; set; }
        [BsonElement("subject", Order = 3)]
        public string subject { get; set; }
        [BsonElement("resource_ids", Order = 4)]
        public ObjectId[]? resource_ids { get; set; }
        [BsonElement("task_ids", Order = 5)]
        public ObjectId[]? task_ids { get; set; }
        [BsonElement("created_at", Order = 6)]
        public DateTime created_at { get; set; }
        [BsonElement("created_by", Order = 7)]
        public ObjectId created_by { get; set; }
        [BsonElement("user_ids", Order = 8)]
        public ObjectId[]? user_ids { get; set; }
        [BsonElement("invited_user_ids", Order = 9)]
        public ObjectId[]? invited_user_ids { get; set; }
        [BsonElement("__v", Order = 10)]
        public int __v { get; set; }

    }

}