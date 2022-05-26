#Set-Wallpaper From Github

$credentials = Get-Credential "expeditors\cjs-josem" -Message "Enter your BBB-User Credentials for image download"

#Download a image from github
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/AlfredoMinjares/images/main/image.jpg" -Outfile C:\temp\PSRansom.jpg -Credential $credentials

$setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
  public const int SetDesktopWallpaper = 20;
  public const int UpdateIniFile = 0x01;
  public const int SendWinIniChange = 0x02;
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  public static void SetWallpaper(string path)
  {
    SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
  }
}
"@
Add-Type -TypeDefinition $setwallpapersrc

[Wallpaper]::SetWallpaper("C:\temp\PSRansom.jpg")