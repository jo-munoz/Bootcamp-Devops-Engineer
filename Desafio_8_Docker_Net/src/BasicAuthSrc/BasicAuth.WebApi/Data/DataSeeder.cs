using BasicAuth.WebApi.DTOs;
using BasicAuth.WebApi.Services;

namespace BasicAuth.WebApi.Data
{
    public class DataSeeder
    {
        public static void SeedUsers(UsersService usersService)
        {
            usersService.CreateUser(new UserDTO
            {
                UserId = Guid.NewGuid(),
                DisplayName = "admin",
                UserName = "Admin",
                Email = "admin@gmail.com",
                Password = "123456",
                CreatedDate = DateTime.Now,
            });
        }
    }
}
