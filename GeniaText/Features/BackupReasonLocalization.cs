namespace GeniaText.Features;

// Presentation-only mapping for legacy display strings returned by BackupBrowserService.
// Do not rewrite backup filenames, metadata, or data files.
internal static class BackupReasonLocalization
{
    internal static string? ResourceKeyFor(string? displayReason) => displayReason switch
    {
        "Запуск программы" => "BackupReasonStartup",
        "Перед импортом" => "BackupReasonBeforeImport",
        "Периодическая" => "BackupReasonPeriodic",
        "Резервная копия" => "BackupReasonGeneric",
        _ => null // Unknown/custom filename reasons remain unchanged.
    };
}
