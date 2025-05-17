# Dotnet Aspire - Custom Infrastructure Bicep Example

This project demonstrates how to use `.AddBicepTemplate()` in a .NET Aspire application to provision custom Azure infrastructure resources. The example shows how to create an Azure Health Data Services FHIR server alongside an Azure Storage account, with event integration between the two services.

## Project Structure

- `Program.cs` - The main Aspire application host
- `Bicep/` - Contains Bicep templates and C# extension methods
  - `azurehealthfhirserver.bicep` - Bicep template for FHIR server provisioning
  - `AzureBicepHealthFhirServer.cs` - C# extension methods for Aspire integration

## How It Works

The application demonstrates a pattern for integrating custom Azure resources using Bicep templates in .NET Aspire:

1. Define your Bicep template (`azurehealthfhirserver.bicep`)
2. Create an extension method to add the resource (`AzureBicepHealthFhirServer.cs`)
3. Use the extension method in your Aspire application host (`Program.cs`)

```csharp
var builder = DistributedApplication.CreateBuilder(args);

var storageAccount = builder.AddAzureStorage("mystorageacct");
var fhirServer = builder.AddHealthDataFhirServer("myazurehealth", storageAccount);

builder.Build().Run();
```

The Bicep template creates:
- An Azure Health Data Services workspace and FHIR server
- Event Grid system topic for FHIR events
- Storage queue subscription for FHIR events

## Additional Resources

- [.NET Aspire Documentation](https://learn.microsoft.com/en-us/dotnet/aspire/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Health Data Services](https://learn.microsoft.com/en-us/azure/healthcare-apis/)

