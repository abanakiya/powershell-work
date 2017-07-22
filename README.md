# SYSTEM:
  Win10 (VM on Linux) Ent. W/S, BRIDGED N/W

# INSTALLED:
  AD Tools;
  SCSM 2012, U2016

# MODULES / CONNECTIONS:
  module: activedirectory;
  module: scsm ('C:\Program Files\Microsoft System Center 2012 R2\Service Manager\PowerShell\System.Center.Service.Manager.psd1');
  module: smlets (https://smlets.codeplex.com/);
  connection: <scsm server name> ("New-SCManagementGroupConnection -ComputerName '<scsm server name>'")
