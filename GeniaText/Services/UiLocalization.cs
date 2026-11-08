using GeniaText.Features;

namespace GeniaText.Services;

internal static class UiLocalization
{
    // The English dictionary is loaded by App.xaml. Russian values override it
    // after settings.json is safely loaded, before any window or tray menu exists.
    internal static void Apply(string? configuredLanguage)
    {
        if (InterfaceLanguagePolicy.Resolve(configuredLanguage) != "Russian")
            return;

        System.Windows.Application.Current.Resources.MergedDictionaries.Add(
            new ResourceDictionary
            {
                Source = new Uri("pack://application:,,,/Localization/Strings.ru.xaml", UriKind.Absolute)
            });
    }

    internal static string Get(string key) =>
        System.Windows.Application.Current.TryFindResource(key) as string ?? key;

    internal static string Format(string key, params object?[] args) =>
        string.Format(System.Globalization.CultureInfo.CurrentCulture, Get(key), args);
}
