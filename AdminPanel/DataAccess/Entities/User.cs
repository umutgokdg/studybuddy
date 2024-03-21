using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace StudyBuddySAP.DataAccess.Entities

{
    [BsonIgnoreExtraElements]
    public class User
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public ObjectId _id { get; set; }
        [BsonElement("first_name")]
        public string first_name { get; set; }
        [BsonElement("last_name")]
        public string last_name { get; set; }
        [BsonElement("hashed_pwd")]
        public string hashed_pwd { get; set; }
        [BsonElement("email")]
        public string email { get; set; }

        //public Object roles { get; set; }
        [BsonElement("points")]
        public int points { get; set; }
        [BsonElement("badge")]
        public string badge { get; set; }
        [BsonElement("created_at")]
        public DateTime created_at { get; set; }
        [BsonElement("status")]
        public string status { get; set; }
        //public string? confirmation_code { get; set; }
        [BsonElement("individual_tasks")]
        public ObjectId[]? individual_tasks { get; set; }
        [BsonElement("__v")]
        public int __v { get; set; }

    }
}
