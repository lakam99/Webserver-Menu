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
    if ((is-service-started($service)) -eq $true) {
        sep-cmd(("Stop-Service $service_name"));
        Write-Host $service_name "stopped.";
    } else {
        Write-Host $service_name "already stopped.";
    }
}


function start-service-if-not {
    param ([string]$service_name);
    $service = throw-if-service-not-exist($service_name);
    if ((is-service-started($service)) -eq $false) {
        sep-cmd(("Start-Service $service_name"));
        Write-Host $service_name "started.";
    } else {
        Write-Host $service_name "already started.";
    }
}

function sep-cmd {
    param ([string]$command, [string]$path);
    $args = "";
    if ($path -ne $null) {
        $args = $args + " Set-Location $path";
    }

    start-process -filepath "powershell" -argumentlist "$args; $command; pause";
    
}

#apache

function start-apache {
    sep-cmd("./apache_start.bat", "C:\xampp");
    Write-Host "Apache started.";
}

function stop-apache {
    sep-cmd("./apache_stop.bat", "C:\xampp");
    Write-Host "Apache halted.";
}


#menu stuff

function process-menu {
    $exit = $false;
    $service = "MySQL56";
    while ($exit -ne $true) {
        print-menu;
        $input = get-menu-input;
        switch ($input) {
            "1" {start-service-if-not($service); start-apache; break;}
            "2" {stop-service-if-not($service); stop-apache; break;}
            "3" {pause; $exit = $true; break;}
        }
    }
}

function get-menu-input {
    return Read-Host "Enter a menu option";
}

function print-menu {
    write-host "1. Start Webserver";
    write-host "2. Stop Webserver";
    write-host "3. Quit";
} 


process-menu;