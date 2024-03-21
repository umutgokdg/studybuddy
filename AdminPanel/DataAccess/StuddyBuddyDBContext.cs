using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MongoDB.Driver;
using MongoDB.EntityFrameworkCore.Extensions;
using StudyBuddySAP.DataAccess.Entities;
using Task = StudyBuddySAP.DataAccess.Entities.Task;

namespace StudyBuddySAP.DataAccess
{
    public class StuddyBuddyDBContext : DbContext
    {
        public DbSet<Group> Groups { get; set; }
        public DbSet<Resource> Resources { get; set; }
        public DbSet<Task> Tasks { get; set; }
        public DbSet<User> Users { get; set; }
        

        public StuddyBuddyDBContext(DbContextOptions<StuddyBuddyDBContext> options)
            : base(options)
        {
        }

            public static StuddyBuddyDBContext Create(IMongoDatabase database) =>
            new(new DbContextOptionsBuilder<StuddyBuddyDBContext>()
           .UseMongoDB(database.Client, database.DatabaseNamespace.DatabaseName)
           .Options);

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            modelBuilder.Entity<Group>().ToCollection("groups");
            modelBuilder.Entity<Resource>().ToCollection("resources");
            modelBuilder.Entity<Task>().ToCollection("tasks");
            modelBuilder.Entity<User>().ToCollection("users");
            base.OnModelCreating(modelBuilder);

        }


    }
}

