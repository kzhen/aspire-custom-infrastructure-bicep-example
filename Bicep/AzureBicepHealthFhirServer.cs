using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Aspire.Hosting.Azure;

public static class AzureBicepHealthFhirServer
{
    public static IResourceBuilder<AzureBicepResource> AddHealthDataFhirServer(this IDistributedApplicationBuilder builder, string name, IResourceBuilder<AzureStorageResource> storage)
    {
        var storageAccountName = ReferenceExpression.Create($"{storage.GetOutput("name")}");

        return builder.AddBicepTemplate(name, "Bicep/azurehealthfhirserver.bicep")
            .WithParameter("storageAccountName", () => storageAccountName)
            .WithParameter("name", name);
    }
}
