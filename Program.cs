using Aspire.Hosting.Azure;

var builder = DistributedApplication.CreateBuilder(args);

var storageAccount = builder.AddAzureStorage("mystorageacct");
var fhirServer = builder.AddHealthDataFhirServer("myazurehealth", storageAccount);

builder.Build().Run();
