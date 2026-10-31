// RUN: dotnet test backend/InvoiceApp.sln --filter "Category=Architecture"
using InvoiceApp.Domain;
using Xunit;

namespace InvoiceApp.Tests;

public class ArchitectureTests
{
    [Fact]
    [Trait("Category", "Architecture")]
    public void Domain_DoesNotReferenceApiOrAspNetCore()
    {
        var violatingAssemblies = typeof(InvoiceApp.Domain.ApprovalService).Assembly
            .GetReferencedAssemblies()
            .Select(assembly => assembly.Name)
            .Where(name => name is not null &&
                (name.StartsWith("InvoiceApp.Api", StringComparison.Ordinal) ||
                 name.StartsWith("Microsoft.AspNetCore", StringComparison.Ordinal)))
            .ToArray();

        Assert.True(
            violatingAssemblies.Length == 0,
            $"InvoiceApp.Domain has forbidden assembly references: {string.Join(", ", violatingAssemblies)}");
    }
}