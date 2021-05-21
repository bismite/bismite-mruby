#include <direct.h>
#include <windows.h>
#include <shellapi.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
  chdir("system");
  ShellExecuteW(NULL,NULL,L"main.exe", GetCommandLineW(),NULL,SW_SHOWNORMAL);
  return 0;
}
