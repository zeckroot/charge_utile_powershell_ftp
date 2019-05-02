#Compte ftp
$user = "utilisateur"
#Mot de passe du compte ftp
$password = "Powershell"
#Dossier source
$localdir = "C:\Scripts\"
#Dossier destination
$ftpdir = "ftp://ftp.server.com/uploads/"
 
$client = New-Object System.Net.WebClient 
$client.Credentials = New-Object System.Net.NetworkCredential($user,$password) 
 
#Debut de la partie création du dossier distant a mettre en remarque si le dossier existe déjà.
$parentfolder = $localdir.split("\")[-1]
Write-Host "Création de $parentfolder"
$makedir = [System.Net.WebRequest]::Create($ftpdir+$parentfolder);
$makedir.Credentials = New-Object System.Net.NetworkCredential($user,$password) 
$makedir.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
$makedir.GetResponse();
#Fin de la partie création du dossier distant
 
 
foreach($item in Get-ChildItem -recurse $localdir){ 
 
    $filename = [system.io.path]::GetFullPath($item.FullName).SubString([system.io.path]::GetFullPath($localdir).Length + 1)
 
    if ($item.Attributes -eq "Directory"){
 
        try{
            Write-Host "Création de $item.Name"
 
            $makedir = [System.Net.WebRequest]::Create($ftpdir+"/"+$parentfolder+"/"+$filename);
            $makedir.Credentials = New-Object System.Net.NetworkCredential($user,$password) 
            $makedir.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
            $makedir.GetResponse();
 
            }
            catch [Net.WebException] {
            Write-Host $item.Name probably exists ...
            }
 
            continue;
        }
 
        Write-Host "Transfert de $item..."
        $file = New-Object System.Uri($ftpdir+"/"+$parentfolder+"/"+$filename) 
        $client.UploadFile($file, $item.FullName)
    }