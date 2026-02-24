# .NET Clean Architecture Bootstrapper

A command-line tool to scaffold and bootstrap ASP.NET Core API solutions following clean architecture principles. Automatically generates a structured solution with separated layers (API, Application, Infrastructure, Domain, and Contracts).

## Features

- **Quick Solution Generation** - Create complete ASP.NET Core solutions in seconds
- **Clean Architecture Template** - Pre-structured layers following industry best practices
- **Multiple .NET Versions** - Support for .NET 6.0 and .NET 10.0+
- **Automated Project Setup** - Projects are created and added to solution automatically
- **Database Folder Support** - Optional SQL Scripts folder structure (for database migrations)
- **Cross-Platform** - Supports Windows and PowerShell environments

## Project Structure

```
.
├── templates/
│   ├── mservice-clean-architecture-dotNET10.ps1    # PowerShell generator for .NET 10
│   └── ms_template_generation_dotNet6.bat          # Batch script generator for .NET 6
├── files/
│   ├── .editorconfig                                # EditorConfig standards
│   ├── .gitignore                                   # Git ignore rules
│   └── .gitattributes                               # Git attributes
└── README.md
```

## Prerequisites

- PowerShell 5.0+ (for .NET 10 template)
- .NET SDK 6.0, 8.0, or 10.0+ (depending on desired version)
- Windows OS

## Usage

### Option 1: .NET 10 (PowerShell)

```powershell
.\templates\mservice-clean-architecture-dotNET10.ps1 `
    -SolutionName 'MyCompany.MyProduct' `
    -RootPath 'C:\my-repos' `
    -CreateDbFolders:$false
```

**Parameters:**
- `-SolutionName` (required): Name of your solution (e.g., `MyCompany.MyProduct`)
- `-RootPath` (required): Root directory where the solution folder will be created
- `-CreateDbFolders` (optional): Create SqlScripts folders for database migrations

**Example:**

```powershell
.\mservice-clean-architecture-dotNET10.ps1 `
    -SolutionName 'MyCompany.MyProduct' `
    -RootPath 'C:\my-repos' `
    -CreateDbFolders:$true
```

### Option 2: .NET 6 (Batch)

```batch
ms_template_generation_dotNet6.bat MyCompany.MyProduct C:\my-repos
```

## Generated Solution Structure

The bootstrapper creates the following project structure:

```
MyCompany.MyProduct/
├── MyCompany.MyProduct.sln
├── MyCompany.MyProduct.API/                 # REST API layer
├── MyCompany.MyProduct.Application/         # Business logic & use cases
├── MyCompany.MyProduct.Infrastructure/      # External services, repositories
├── MyCompany.MyProduct.Domain/              # Entities, value objects, domain logic
├── MyCompany.MyProduct.Contracts/           # DTOs, interfaces, shared contracts
└── SqlScripts/ (optional)                   # Database migration scripts
```

## Clean Architecture Layers

- **API Layer** - Entry point, controllers, HTTP handling
- **Application Layer** - Use cases, business logic, application services
- **Domain Layer** - Core business entities and domain logic
- **Infrastructure Layer** - Database access, external services, repositories
- **Contracts Layer** - Shared DTOs, interfaces, service contracts

## Getting Started

1. Clone this repository
2. Navigate to the `templates` directory
3. Run the appropriate script for your .NET version
4. Navigate to the generated solution folder
5. Start building your API!

```powershell
cd templates
.\mservice-clean-architecture-dotNET10.ps1 -SolutionName 'Acme.API' -RootPath 'C:\dev'
cd C:\dev\Acme.API
dotnet build
dotnet run --project .\Acme.API\Acme.API.csproj
```

## Configuration Files

The bootstrapper includes default configuration files:

- **`.editorconfig`** - Consistent code style across the team
- **`.gitignore`** - Standard .NET ignore patterns
- **`.gitattributes`** - Git line ending handling

## Troubleshooting

### Script Execution Policy Error

If you get an execution policy error on Windows:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Solution Not Found

Ensure you provide both `-SolutionName` and `-RootPath` parameters and that the root directory exists.

### Projects Not Added to Solution

Check that all required .NET SDK versions are installed and accessible via the `dotnet` CLI.

## Contributing

Contributions are welcome! Please feel free to submit pull requests with improvements or additional templates for other .NET versions.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
