function throw-if-service-not-exist {
    param ([string]$service_name);
    $service_exists = Get-Service $service_name;
    if ($service_exists -eq $null) {
        write-host "Failed to find service" $service_name;
        pause;
        exit;
    } else {
        return $service_exists;
    }

}

function is-service-started ($service) {
    $service_status = $service | findstr "Stopped";
    if ($service_status -eq "null") {
        return $true;
    } else {
        return $false;
    }
}

function stop-service-if-not {
    param ([string]$service_name);
    $service = throw-if-service-not-exist($service_name);
    if ($service.CanStop) {
        stop-service $service_name;
        Write-Host $service_name "stopped.";
    } else {
        Write-Host $service_name "already stopped.";
    }
}


function start-service-if-not {
    param ([string]$service_name);
    $service = throw-if-service-not-exist($service_name);
    if ((is-service-started($service)) -eq $false) {
        start-service $service_name;
        Write-Host $service_name "started.";
    } else {
        Write-Host $service_name "already started.";
    }
}

function restart-webserver($service) {
    stop-service-if-not($service);
    start-service-if-not $service;
    stop-apache;
    start-apache;

}


#apache

function start-apache {
    set-location "C:\xampp";
    Invoke-Expression "cmd /c start powershell -command {./apache_start.bat;}";
    Write-Host "Apache started.";
}

function stop-apache {
    set-location "C:\xampp";
    invoke-expression "cmd /c call powershell -command {./apache_stop.bat;}";
    Write-Host "Apache halted.";
}

#github

function commit-branch ($branch_name) {
    Set-Location "C:\xampp\htdocs\amazonRanker\";
    $cmd = -join("cmd /c git push origin ", $branch_name);
    invoke-expression $cmd;
    Set-Location "C:\";
}


#menu stuff

function process-menu {
    $exit = $false;
    $service = "MySQL56";
    $branch = "az4";
    while ($exit -ne $true) {
        print-menu;
        $input = get-menu-input;
        switch ($input) {
            "1" {start-service-if-not($service); start-apache; break;}
            "2" {stop-service-if-not($service); stop-apache; break;}
            "3" {commit-branch($branch); break;}
            "4" {pause; $exit = $true; break;}
        }
    }
    Set-Location "C:\";
}

function get-menu-input {
    return Read-Host "Enter a menu option";
}

function print-menu {
    write-host "1. Start Webserver";
    write-host "2. Stop Webserver";
    write-host "3. Commit az4 to github";
    write-host "4. Quit";
} 


process-menu;
