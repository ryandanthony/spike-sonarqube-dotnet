#!/usr/bin/env pwsh
$version = "1.0.1"
$build_configuration = "RELEASE"

# Assigning Global Variables
$sonarqubeUrl = "https://sonarqube.ants.zone"
#$sonarqubeUrl = $null
$sonarqubeToken = ""
$sonarqubeProjectKey = "spike2"

Push-Location ./src
   if ($null -ne $sonarqubeUrl) {
      # Sonarscanner for static analysis
      dotnet tool install --global dotnet-sonarscanner

      Write-Output "setting up sonarqube scanning"
      dotnet sonarscanner begin /k:$sonarqubeProjectKey `
      /d:sonar.host.url=$sonarqubeUrl `
      /d:sonar.login=$sonarqubeToken `
      /v:$version `
      /d:sonar.cs.xunit.reportsPaths=**/*.testresults.xml `
      /d:sonar.cs.opencover.reportsPaths=**/*.coverage.xml `
      /d:sonar.scm.provider=git
   }
   dotnet clean -p:Configuration=$build_configuration
   dotnet msbuild -t:Restore,Build -p:Configuration=$build_configuration -p:Version=$version
   if (! ($?)) {
      throw "build fail"
   }
   Push-Location ./Spike.Tests
    dotnet test . --logger:"xunit;LogFilePath=../TestResults/Spike.Tests.$version.testresults.xml" -c $build_configuration /p:AltCover=true /p:AltCoverForce=true --no-build --test-adapter-path:.
    Move-Item ./coverage.xml ../TestResults/Spike.Tests.$version.coverage.xml -ErrorAction Ignore
   Pop-Location

   if ( $null -ne $sonarqubeUrl) {
        Write-Output "stopping sonarqube scanning"
        dotnet sonarscanner end /d:sonar.login=$sonarqubeToken
   }
 Pop-Location