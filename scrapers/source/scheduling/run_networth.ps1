# Show a Windows notification
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$template = [Windows.UI.Notifications.ToastTemplateType]::ToastText01
$xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
$xml.GetElementsByTagName("text").Item(0).AppendChild($xml.CreateTextNode("NetWorth scraper is about to run.")) > $null
$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("NetWorth App")
$notifier.Show($toast)

# Run the EXE
Start-Process "C:\Users\rodri\Desktop\Projetos\networth\scrapers\dist\main.exe"