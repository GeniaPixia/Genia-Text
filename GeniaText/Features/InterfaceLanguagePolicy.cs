using System.Globalization;

namespace GeniaText.Features;

internal static class InterfaceLanguagePolicy
{
    internal static string Normalize(string? preference)
    {
        if (string.Equals(preference, "Russian", StringComparison.OrdinalIgnoreCase)) return "Russian";
        if (string.Equals(preference, "English", StringComparison.OrdinalIgnoreCase)) return "English";
        return "Auto";
    }

    internal static string Resolve(string? preference, CultureInfo? windowsUiCulture = null)
    {
        string setting = Normalize(preference);
        if (setting != "Auto") return setting;
        CultureInfo culture = windowsUiCulture ?? CultureInfo.CurrentUICulture;
        return string.Equals(culture.TwoLetterISOLanguageName, "ru", StringComparison.OrdinalIgnoreCase)
            ? "Russian" : "English";
    }
}
