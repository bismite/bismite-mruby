#include <direct.h>
#include <windows.h>
#include <shellapi.h>
#include <libgen.h>
#include <stdio.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
  char exepath[4096];
  GetModuleFileName(NULL,exepath,4096);
  char *dirpath = dirname(exepath);
  chdir(dirpath);
  chdir("system");
  ShellExecute(NULL,NULL,"main.exe", GetCommandLine(),NULL,SW_SHOWNORMAL);
  return 0;
}
