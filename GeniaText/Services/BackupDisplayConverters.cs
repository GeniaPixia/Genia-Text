using System.Globalization;
using System.Windows.Data;
using GeniaText.Features;

namespace GeniaText.Services;

// Only window-facing formatting: no changes to backup storage or restore.
public sealed class BackupReasonDisplayConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        string reason = value as string ?? string.Empty;
        string? resourceKey = BackupReasonLocalization.ResourceKeyFor(reason);
        return resourceKey is null ? reason : UiLocalization.Get(resourceKey);
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) =>
        Binding.DoNothing;
}

public sealed class BackupSizeDisplayConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is not long bytes || bytes < 0) return string.Empty;
        return bytes < 1024
            ? UiLocalization.Format("BackupSizeBytes", bytes)
            : UiLocalization.Format("BackupSizeKilobytes", bytes / 1024d);
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) =>
        Binding.DoNothing;
}
