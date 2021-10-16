using Microsoft.EntityFrameworkCore;

namespace PlatformService.Data
{   
    using PlatformService.Models;

    public class PlatformDbContext : DbContext
    {
        public PlatformDbContext(DbContextOptions<PlatformDbContext> options) : base(options) {}

        public DbSet<Platform> Platforms { get; set;}
    }
}
