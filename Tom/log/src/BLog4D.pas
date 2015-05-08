unit BLog4D;

interface uses Log4D,Classes, Windows, SysUtils, BDebug;

type TBLog4DInfo = record
  FLoggerName: string;
  FUnitName  : string;
  FMethodName: string;
end;

 procedure BLog4DConfigure(APropertyFileName: String);

 // Main Logging Methods
 procedure LogFatal(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
 procedure LogError(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
 procedure LogWarn (ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
 procedure LogInfo (ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
 procedure LogDebug(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil); overload;

 procedure LogDebug(ALogMessage: string; ALogInfo: TBLog4DInfo; const Ex: Exception = nil); overload;
 procedure InitDefaultLogFile;

const
  GIT_TEMP_LOG_PATH       = 'GiT\realax\Log\';
  LOG_SETTINGS_FILENAME   = 'logging.properties';

  FALLBACK_SETTING        = 'FALLBACK_SETTING';
  GIT_FALLBACK_LOGGER     = 'GIT_CONSOLE_LOGGER';

  LOGGER_TOM              = 'ToMLogger';
  LOGGER_CONSOLE          = 'DefaultConsoleLogger';

var
  BLog4D_CurrentLogPropertiesFile    : string;
  BLog4D_CurrentLogger               : TLogLogger;

implementation uses Dialogs;

procedure SetCurrentLogger(ALogger: string);
begin
  if(Length(ALogger) > 0) then
  begin
    
    //LogDebug('@BLog4D.SetCurrentLogger: Setting Logger To [' + ALogger +']');// StackOverFlow
    BLog4D_CurrentLogger := LogLog.GetLogger(ALogger);
  end;
end;

// Main Logging Methods

procedure LogFatal(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
begin
 SetCurrentLogger(ALoggerName);
 BLog4D_CurrentLogger.Fatal(ALogMessage,Ex);
end;

procedure LogError(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
begin
 SetCurrentLogger(ALoggerName);
 BLog4D_CurrentLogger.Error(ALogMessage,Ex);
end;

procedure LogWarn (ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
begin
 SetCurrentLogger(ALoggerName);
 BLog4D_CurrentLogger.Warn(ALogMessage,Ex);
end;

procedure LogInfo (ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
begin
 SetCurrentLogger(ALoggerName);
 BLog4D_CurrentLogger.Info(ALogMessage,Ex);
end;

procedure LogDebug(ALogMessage: string; const ALoggerName : string=''; const Ex: Exception = nil);
begin
 SetCurrentLogger(ALoggerName);
 BLog4D_CurrentLogger.Debug(ALogMessage,Ex);
end;

procedure LogDebug(ALogMessage: string; ALogInfo: TBLog4DInfo; const Ex: Exception = nil);
begin
 LogDebug('['+ALogInfo.FUnitName+'] ['+ALogInfo.FMethodName+'] :' + ALogMessage,ALogInfo.FLoggerName,Ex);
end;

procedure BLog4DConfigure(APropertyFileName: String);
begin
  TLogPropertyConfigurator.ResetConfiguration;
  if ((Assigned(BLog4D_CurrentLogger)) AND (Length(BLog4D_CurrentLogger.Name) > 0)) then
  begin
   LogDebug('@BLog4DConfigure: Switching from [' + BLog4D_CurrentLogPropertiesFile + '] to ['+APropertyFileName+']');
  end;

  if  (     (not(AnsiCompareStr(APropertyFileName,FALLBACK_SETTING) = 0))
        AND (FileExists(APropertyFileName))
      ) then
  begin
    TLogPropertyConfigurator.Configure(APropertyFileName);
    //LogLog.Hierarchy.EmitNoAppenderWarning(TLogLogger.GetRootLogger);

    BLog4D_CurrentLogPropertiesFile := APropertyFileName;
    BLog4D_CurrentLogger := TLogLogger.GetLogger(LOGGER_CONSOLE);
  end
  else
    begin
      TLogBasicConfigurator.Configure();
      BLog4D_CurrentLogPropertiesFile := '';
      BLog4D_CurrentLogger := TLogLogger.GetLogger(GIT_FALLBACK_LOGGER);
    end;
  LogDebug('@BLog4DConfigure: CurrentLogger is ['+BLog4D_CurrentLogger.Name+']');
end;

function CreateDefaultDirStructure(ATempDir: string): Boolean;
begin
  Result := ForceDirectories(ATempDir);
end;

procedure InitDefaultLogFile;
var
  Stream: TResourceStream;
  ADest: string;
  FTmpDir: string;
begin
	try
	Stream := TResourceStream.Create(hInstance,'LOGSETTINGS', RT_RCDATA);
	try	
      FTmpDir := GetTempVerzeichnis;

      ADest := FTmpDir + GIT_TEMP_LOG_PATH + LOG_SETTINGS_FILENAME;
	
      if not FileExists(ADest) then
      begin
     
	   if not DirectoryExists(ExtractFilePath(ADest)) then
        begin
       
		  if CreateDefaultDirStructure(ExtractFilePath(ADest)) then
          begin
         
			Stream.SaveToFile(ADest);
          end;
        end;
      end;

      if(FileExists(ADest)) then 
	  begin
		BLog4DConfigure(ADest);
	  end
      else 
	  begin
	  end;
    except on E:Exception do
    begin
	  BLog4DConfigure(FALLBACK_SETTING);
      LogError(E.Message);
    end;
    end;
    finally
      Stream.Free;
    end;
end;

// TODO Als Parameter einbindbar machen;
function sDbgFN: string;
var
  buffer: array[0..255] of char;
begin
  GetModuleFilename(HInstance, addr(buffer), sizeof(buffer));
  Result := lowercase(buffer);
end;

initialization
 InitDefaultLogFile;


finalization
 BLog4D_CurrentLogger.Free;
end.
