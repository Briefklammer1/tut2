namespace PlatformService.Data
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using PlatformService.Models;

    public class PlatformRepo : IPlatformRepo
    {
        private readonly PlatformDbContext _context;

        public PlatformRepo(PlatformDbContext context)
        {
            _context = context;
        }

        public void Create(Platform platform)
        {
            if(platform == null)
            {
                throw new ArgumentNullException(nameof(platform));
            }

            _context.Platforms.Add(platform);
        }

        public IEnumerable<Platform> GetAll()
        {
            return _context.Platforms.ToList();
        }

        public Platform GetById(int id)
        {
            return _context.Platforms.FirstOrDefault(p => p.Id == id);
        }

        public bool SaveChanges()
        {
            return (_context.SaveChanges() >= 0);
        }
    }
}
