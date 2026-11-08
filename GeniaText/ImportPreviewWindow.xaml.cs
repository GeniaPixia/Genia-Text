using GeniaText.Features;
using GeniaText.Services;

namespace GeniaText;

public enum ImportApplyMode
{
    Append,
    Replace
}

public partial class ImportPreviewWindow : Window
{
    public ImportPreviewWindow(ImportPreviewResult preview)
    {
        InitializeComponent();
        PreviewList.ItemsSource = preview.Items;
        SummaryText.Text =
            UiLocalization.Format("ImportSummary", preview.SourceCount, preview.NewCount,
                preview.DuplicateCount, preview.IdConflictCount) +
            (preview.SkippedEmptyCount > 0
                ? UiLocalization.Format("ImportSkippedEmpty", preview.SkippedEmptyCount)
                : string.Empty);
    }

    public ImportApplyMode? SelectedMode { get; private set; }

    private void Append_Click(object sender, RoutedEventArgs e)
    {
        SelectedMode = ImportApplyMode.Append;
        DialogResult = true;
    }

    private void Replace_Click(object sender, RoutedEventArgs e)
    {
        MessageBoxResult confirmation = MessageBox.Show(
            UiLocalization.Get("ImportReplaceConfirm"),
            UiLocalization.Get("ImportDialogCaption"), MessageBoxButton.YesNo, MessageBoxImage.Question);
        if (confirmation != MessageBoxResult.Yes) return;
        SelectedMode = ImportApplyMode.Replace;
        DialogResult = true;
    }

    private void Cancel_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
    }
}
