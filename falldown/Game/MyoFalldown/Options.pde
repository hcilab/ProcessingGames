//================================================================================================
// Author: Carly Smith
//
// Manages the save data xml file containing application options.
//================================================================================================

//------------------------------------------------------------------------------------------------
// INTERFACE
// The options object is a container for four inner objects which each handle
// different sections of the options XML file.
//------------------------------------------------------------------------------------------------

public interface IOptions
{
  public IGameOptions getGameOptions();
  public IIOOptions getIOOptions();
  public IStats getStats();
  public ICustomizeOptions getCustomizeOptions();
  public ICredits getCredits();
  public IUserInformation getUserInformation();
}

enum ControlPolicy
{
  NORMAL,
  DIRECTION_ASSIST,
  SINGLE_MUSCLE,
}

enum DirectionAssistMode
{
  LEFT_ONLY,
  RIGHT_ONLY,
  BOTH,
}

enum SingleMuscleMode
{
  AUTO_LEFT,
  AUTO_RIGHT,
}

public interface IGameOptions
{
  public int getStartingLevel();
  public boolean getLevelUpOverTime();
  public ControlPolicy getControlPolicy();
  public DirectionAssistMode getDirectionAssistMode();
  public SingleMuscleMode getSingleMuscleMode();
  public boolean getObstacles();
  public boolean getPlatformMods();
  
  public void setStartingLevel(int startingLevel);
  public void setLevelUpOverTime(boolean levelUpOverTime);
  public void setControlPolicy(ControlPolicy policy);
  public void setDirectionAssistMode(DirectionAssistMode mode);
  public void setSingleMuscleMode(SingleMuscleMode mode);
  public void setObstacles(boolean obstacles);
  public void setPlatformMods(boolean platformMods);
}

enum EmgSamplingPolicy
{
  DIFFERENCE,
  MAX,
  FIRST_OVER,
}

public interface IIOOptions
{
  public float getMusicVolume();
  public float getSoundEffectsVolume();
  public float getLeftEMGSensitivity();
  public float getRightEMGSensitivity();
  public EmgSamplingPolicy getEmgSamplingPolicy();

  
  public void setMusicVolume(float volume);
  public void setSoundEffectsVolume(float volume);
  public void setLeftEMGSensitivity(float sensitivity);
  public void setRightEMGSensitivity(float sensitivity);
  public void setEmgSamplingPolicy(EmgSamplingPolicy policy);
}

public interface IStats
{
  public ArrayList<IGameRecord> getGameRecords();
  
  public IGameRecord createGameRecord();
  public void addGameRecord(IGameRecord record);
  public void clear();
}

public interface IGameRecord
{
  public Comparator<IGameRecord> createByLevelAchievedComparator();
  public Comparator<IGameRecord> createByScoreAchievedComparator();
  public Comparator<IGameRecord> createByTimePlayedComparator();
  public Comparator<IGameRecord> createByAverageSpeedComparator();
  public Comparator<IGameRecord> createByCoinsCollectedComparator();
  public Comparator<IGameRecord> createByDateComparator();

  public int getLevelAchieved();
  public int getScoreAchieved();
  public int getTimePlayed();
  public float getAverageSpeed();
  public int getCoinsCollected();
  public long getDate();
  
  public void setLevelAchieved(int levelAchieved);
  public void setScoreAchieved(int scoreAchieved);
  public void setTimePlayed(int timePlayed);
  public void setAverageSpeed(float averageSpeed);
  public void setCoinsCollected(int coinsCollected);
  public void setDate(long date);
}

public interface ICustomizeOptions
{
  public int getCoinsCollected();
  public String getBackground();
  public String getOpacityBackground();

  public void setCoinsCollected(int _newCoins);
  public void setCoinsAfterPurchase(int _price);
  public void setPlayer(int _newActivePlayerIndex);
  public void setPlatform(int _newActivePlatformIndex, int _id);
  public void setCoin(int _newActiveCoinIndex, int _id);
  public void setObstacle(int _newActiveObstacleIndex, int _id);
  public void setBackground(int _newActiveBackgroundIndex, int _id);
  public void setMusic(int _newActiveMusicIndex, int _id);

  public void purchase(int _custSpriteIndex);
  public void preparePurchaseScreen(int _custSpriteIndex, RenderComponent renderComponent);
}

public interface IGameRecordViewHelper
{
  public String getLevelAchieved();
  public String getScoreAchieved();
  public String getTimePlayed();
  public String getAverageSpeed();
  public String getCoinsCollected();
  public String getDate();
}

public interface ICredits
{
  public boolean isAnonymous();
}

public interface IUserInformation
{
  public void getDefaultSetting();
  public void setSaveDataFile(String loginID);
  public String getUserID();
}
//------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------

public class Options implements IOptions
{
  private  String SAVE_DATA_FILE_NAME_IN = "xml_data/save_data.xml";
  private  String SAVE_DATA_FILE_NAME_OUT = "data/xml_data/save_data.xml";
  private final String SAVE_DATA_DEFAULT_FILE = "xml_data/default_save_data.xml";
  private XML xmlSaveData;
  private XML xmldefaultData;
  
  private IGameOptions gameOptions;
  private IStats stats;
  private IIOOptions IOOptions;
  private ICustomizeOptions customizeOptions;
  private ICredits credits;
  private IUserInformation userInfo;
  
  public Options()
  {
    
    xmldefaultData = loadXML(SAVE_DATA_DEFAULT_FILE);
    userInfo = new UserInformation();
    
    xmlSaveData = loadXML(SAVE_DATA_FILE_NAME_IN);
    gameOptions = new GameOptions();
    stats = new Stats();
    IOOptions = new IOOptions();
    customizeOptions = new CustomizeOptions();
    credits = new Credits();
  }
  
  public void reloadOptions(){
    userInfo = new UserInformation();
    xmlSaveData = loadXML(SAVE_DATA_FILE_NAME_IN);
    gameOptions = new GameOptions();
    stats = new Stats();
    IOOptions = new IOOptions();
    customizeOptions = new CustomizeOptions();
    credits = new Credits();
  }
  
  @Override public IGameOptions getGameOptions()
  {
    return gameOptions;
  }
  
  @Override public IStats getStats()
  {
    return stats;
  }

  @Override public IIOOptions getIOOptions()
  {
    return IOOptions;
  }
  
  @Override public ICustomizeOptions getCustomizeOptions()
  {
    return customizeOptions;
  }

  @Override public ICredits getCredits()
  {
    return credits;
  }
  
  @Override public IUserInformation getUserInformation()
  {
    return userInfo;
  }
  //--------------------------------------------
  // GAME OPTIONS
  //--------------------------------------------
  public class GameOptions implements IGameOptions
  {
    private final String XML_GAME = "Game";
    private final String STARTING_LEVEL = "starting_level";
    private final String LEVEL_UP_OVER_TIME = "level_up_over_time";
    private final String CONTROL_POLICY = "control_policy";
    private final String DIRECTION_ASSIST_MODE = "direction_assist_mode";
    private final String SINGLE_MUSCLE_MODE = "single_muscle_mode";
    private final String OBSTACLES = "obstacles";
    private final String PLATFORM_MODS = "platform_mods";
    
    private XML xmlGame;
    
    private int startingLevel;
    private boolean levelUpOverTime;
    private ControlPolicy controlPolicy;
    private DirectionAssistMode directionAssistMode;
    private SingleMuscleMode singleMuscleMode;
    private boolean obstacles;
    private boolean platformMods;
    
    private GameOptions()
    {
      xmlGame = xmlSaveData.getChild(XML_GAME);
      
      startingLevel = xmlGame.getInt(STARTING_LEVEL);
      levelUpOverTime = xmlGame.getString(LEVEL_UP_OVER_TIME).equals("true") ? true : false;
      obstacles = xmlGame.getString(OBSTACLES).equals("true") ? true : false;
      platformMods = xmlGame.getString(PLATFORM_MODS).equals("true") ? true : false;

      switch (xmlGame.getString(CONTROL_POLICY))
      {
        case ("normal"):
          controlPolicy = ControlPolicy.NORMAL; break;
        case ("direction_assist"):
          controlPolicy = ControlPolicy.DIRECTION_ASSIST; break;
        case ("single_muscle"):
          controlPolicy = ControlPolicy.SINGLE_MUSCLE; break;
        default:
          println("[ERROR] Invalid control policy specified while parsing game options.");
          break;
      }

      switch (xmlGame.getString(DIRECTION_ASSIST_MODE)) 
      {
        case ("left_only"):
          directionAssistMode = DirectionAssistMode.LEFT_ONLY; break;
        case ("right_only"):
          directionAssistMode = DirectionAssistMode.RIGHT_ONLY; break;
        case ("both"):
          directionAssistMode = DirectionAssistMode.BOTH; break;
        default:
          println("[ERROR] Invalid direction assist mode specified while parsing game options.");
          break;
      }

      switch (xmlGame.getString(SINGLE_MUSCLE_MODE)) 
      {
        case ("auto_left"):
          singleMuscleMode = SingleMuscleMode.AUTO_LEFT; break;
        case ("auto_right"):
          singleMuscleMode = SingleMuscleMode.AUTO_RIGHT; break;
        default:
          println("[ERROR] Invalid single muscle mode specified while parsing game options.");
          break;
      }
    }
    
    @Override public int getStartingLevel()
    {
      return startingLevel;
    }
    
    @Override public boolean getLevelUpOverTime()
    {
      return levelUpOverTime;
    }
    
    public ControlPolicy getControlPolicy()
    {
      return controlPolicy;
    }

    public DirectionAssistMode getDirectionAssistMode()
    {
      return directionAssistMode;
    }

    public SingleMuscleMode getSingleMuscleMode()
    {
      return singleMuscleMode;
    }

    @Override public boolean getObstacles()
    {
      return obstacles;
    }
    
    @Override public boolean getPlatformMods()
    {
      return platformMods;
    }
    
    @Override public void setStartingLevel(int _startingLevel)
    {
      startingLevel = _startingLevel;
      xmlGame.setInt(STARTING_LEVEL, startingLevel);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setLevelUpOverTime(boolean _levelUpOverTime)
    {
      levelUpOverTime = _levelUpOverTime;
      xmlGame.setString(LEVEL_UP_OVER_TIME, levelUpOverTime ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    public void setControlPolicy(ControlPolicy policy)
    {
      controlPolicy = policy;

      if (controlPolicy == ControlPolicy.NORMAL)
        xmlGame.setString(CONTROL_POLICY, "normal");
      else if (controlPolicy == ControlPolicy.DIRECTION_ASSIST)
        xmlGame.setString(CONTROL_POLICY, "direction_assist");
      else if (controlPolicy == ControlPolicy.SINGLE_MUSCLE)
        xmlGame.setString(CONTROL_POLICY, "single_muscle");
      else
        println("[ERROR] Unrecognized control policy specified in GameOptions::setControlPolicy()");

      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setDirectionAssistMode(DirectionAssistMode mode)
    {
      directionAssistMode = mode;

      if (directionAssistMode == DirectionAssistMode.LEFT_ONLY)
        xmlGame.setString(DIRECTION_ASSIST_MODE, "left_only");
      else if (directionAssistMode == DirectionAssistMode.RIGHT_ONLY)
        xmlGame.setString(DIRECTION_ASSIST_MODE, "right_only");
      else if (directionAssistMode == DirectionAssistMode.BOTH)
        xmlGame.setString(DIRECTION_ASSIST_MODE, "both");
      else
        println("[ERROR] Unrecognized direction assist mode specified in GameOptions::setDirectionAssistMode()");

      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setSingleMuscleMode(SingleMuscleMode mode)
    {
      singleMuscleMode = mode;

      if (singleMuscleMode == SingleMuscleMode.AUTO_LEFT)
        xmlGame.setString(SINGLE_MUSCLE_MODE, "auto_left");
      else if (singleMuscleMode == SingleMuscleMode.AUTO_RIGHT)
        xmlGame.setString(SINGLE_MUSCLE_MODE, "auto_right");
      else
        println("[ERROR] Unrecognized single muscle mode specified in GameOptions::setSingleMuscleMode()");

      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setObstacles(boolean _obstacles)
    {
      obstacles = _obstacles;
      xmlGame.setString(OBSTACLES, obstacles ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void setPlatformMods(boolean _platformMods)
    {
      platformMods = _platformMods;
      xmlGame.setString(PLATFORM_MODS, platformMods ? "true" : "false");
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
  }

  //--------------------------------------------
  // IO OPTIONS
  //--------------------------------------------
  public class IOOptions implements IIOOptions
  {
    private final String XML_IO = "IO";
    private final String MUSIC_VOLUME = "music_volume";
    private final String SOUND_EFFECTS_VOLUME = "sound_effects_volume";
    private final String LEFT_EMG_SENSITIVITY = "left_emg_sensitivity";
    private final String RIGHT_EMG_SENSITIVITY = "right_emg_sensitivity";
    private final String EMG_SAMPLING_POLICY = "emg_sampling_policy";
    
    private XML xmlIO;
    
    private float musicVolume;
    private float soundEffectsVolume;
    private float leftEMGSensitivity;
    private float rightEMGSensitivity;
    private EmgSamplingPolicy emgSamplingPolicy;

    private IOOptions()
    {
      xmlIO = xmlSaveData.getChild(XML_IO);
      
      musicVolume = xmlIO.getFloat(MUSIC_VOLUME);
      soundEffectsVolume = xmlIO.getFloat(SOUND_EFFECTS_VOLUME);
      leftEMGSensitivity = xmlIO.getFloat(LEFT_EMG_SENSITIVITY);
      rightEMGSensitivity = xmlIO.getFloat(RIGHT_EMG_SENSITIVITY);

      switch (xmlIO.getString(EMG_SAMPLING_POLICY))
      {
        case ("max"):
          emgSamplingPolicy = EmgSamplingPolicy.MAX; break;
        case ("difference"):
          emgSamplingPolicy = EmgSamplingPolicy.DIFFERENCE; break;
        case ("first_over"):
          emgSamplingPolicy = EmgSamplingPolicy.FIRST_OVER; break;
        default:
          println("[ERROR] Unrecognized emg sampling policy while parsing IOOptions");
          break;
      }
    }

    @Override public float getMusicVolume()
    {
      return musicVolume;
    }

    @Override public float getSoundEffectsVolume()
    {
      return soundEffectsVolume;
    }

    @Override public float getLeftEMGSensitivity()
    {
      return leftEMGSensitivity;
    }

    @Override public float getRightEMGSensitivity()
    {
      return rightEMGSensitivity;
    }
    
    public EmgSamplingPolicy getEmgSamplingPolicy()
    {
      return emgSamplingPolicy;
    }

    @Override public void setMusicVolume(float volume)
    {
      musicVolume = volume / 100.0f;
      xmlIO.setFloat(MUSIC_VOLUME, musicVolume);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setSoundEffectsVolume(float volume)
    {
      soundEffectsVolume = volume / 100.0f;
      xmlIO.setFloat(SOUND_EFFECTS_VOLUME, soundEffectsVolume);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setLeftEMGSensitivity(float sensitivity)
    {
      leftEMGSensitivity = sensitivity;
      xmlIO.setFloat(LEFT_EMG_SENSITIVITY, leftEMGSensitivity);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    @Override public void setRightEMGSensitivity(float sensitivity)
    {
      rightEMGSensitivity = sensitivity;
      xmlIO.setFloat(RIGHT_EMG_SENSITIVITY, rightEMGSensitivity);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    public void setEmgSamplingPolicy(EmgSamplingPolicy policy)
    {
      emgSamplingPolicy = policy;

      if (emgSamplingPolicy == EmgSamplingPolicy.MAX)
        xmlIO.setString(EMG_SAMPLING_POLICY, "max");
      else if (emgSamplingPolicy == EmgSamplingPolicy.DIFFERENCE)
        xmlIO.setString(EMG_SAMPLING_POLICY, "difference");
      else if (emgSamplingPolicy == EmgSamplingPolicy.FIRST_OVER)
        xmlIO.setString(EMG_SAMPLING_POLICY, "first_over");
      else
        println("[ERROR] Unrecognized emg sampling policy in IOOptions::setEmgSamplingPolicy()");

      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
  }
  
  //--------------------------------------------
  // STATS OPTIONS
  //--------------------------------------------
  public class Stats implements IStats
  {
    public class GameRecord implements IGameRecord
    {
      private int levelAchieved;
      private int scoreAchieved;
      private int timePlayed;
      private float averageSpeed;
      private int coinsCollected;
      private long date;
      
      public GameRecord()
      {
        levelAchieved = -1;
        scoreAchieved = -1;
        timePlayed = -1;
        averageSpeed = -1.0f;
        coinsCollected = -1;
        date = -1;
      }

      @Override public Comparator<IGameRecord> createByLevelAchievedComparator()
      {
        return new ByLevelAchievedComparator();
      }

      @Override public Comparator<IGameRecord> createByScoreAchievedComparator()
      {
        return new ByScoreAchievedComparator();
      }

      @Override public Comparator<IGameRecord> createByTimePlayedComparator()
      {
        return new ByTimePlayedComparator();
      }

      @Override public Comparator<IGameRecord> createByAverageSpeedComparator()
      {
        return new ByAverageSpeedComparator();
      }

      @Override public Comparator<IGameRecord> createByCoinsCollectedComparator()
      {
        return new ByCoinsCollectedComparator();
      }

      @Override public Comparator<IGameRecord> createByDateComparator()
      {
        return new ByDateComparator();
      }
      
      @Override public int getLevelAchieved()
      {
        return levelAchieved;
      }
      
      @Override public int getScoreAchieved()
      {
        return scoreAchieved;
      }
      
      @Override public int getTimePlayed()
      {
        return timePlayed;
      }
      
      @Override public float getAverageSpeed()
      {
        return averageSpeed;
      }
      
      @Override public int getCoinsCollected()
      {
        return coinsCollected;
      }
      
      @Override public long getDate()
      {
        return date;
      }
      
      @Override public void setLevelAchieved(int _levelAchieved)
      {
        levelAchieved = _levelAchieved;
      }
      
      @Override public void setScoreAchieved(int _scoreAchieved)
      {
        scoreAchieved = _scoreAchieved;
      }
      
      @Override public void setTimePlayed(int _timePlayed)
      {
        timePlayed = _timePlayed;
      }
      
      @Override public void setAverageSpeed(float _averageSpeed)
      {
        averageSpeed = _averageSpeed;
      }
      
      @Override public void setCoinsCollected(int _coinsCollected)
      {
        coinsCollected = _coinsCollected;
      }
      
      @Override public void setDate(long _date)
      {
        date = _date;
      }
    }
    
    private final String XML_STATS = "Stats";
    private final String XML_RECORD = "Record";
    private final String XML_LEVEL_ACHIEVED = "level";
    private final String XML_SCORE_ACHIEVED = "score";
    private final String XML_TIME_PLAYED = "time_played_millis";
    private final String XML_AVERAGE_SPEED = "avg_speed";
    private final String XML_COINS_COLLECTED = "coins_collected";
    private final String XML_DATE = "date";
    
    private XML xmlStats;
    private ArrayList<IGameRecord> gameRecords;
    
    private Stats()
    {
      xmlStats = xmlSaveData.getChild(XML_STATS);
      
      gameRecords = new ArrayList<IGameRecord>();
      
      for (XML xmlRecord : xmlStats.getChildren())
      {
        if (xmlRecord.getName().equals(XML_RECORD))
        {
          IGameRecord record = new GameRecord();
          record.setLevelAchieved(xmlRecord.getInt(XML_LEVEL_ACHIEVED));
          record.setScoreAchieved(xmlRecord.getInt(XML_SCORE_ACHIEVED));
          record.setTimePlayed(xmlRecord.getInt(XML_TIME_PLAYED));
          record.setAverageSpeed(xmlRecord.getFloat(XML_AVERAGE_SPEED));
          record.setCoinsCollected(xmlRecord.getInt(XML_COINS_COLLECTED));
          record.setDate(Long.parseLong(xmlRecord.getString(XML_DATE)));
          gameRecords.add(record);
        }
      }
    }
    
    @Override public ArrayList<IGameRecord> getGameRecords()
    {
      return gameRecords;
    }
    
    @Override public IGameRecord createGameRecord()
    {
      return new GameRecord();
    }
  
    @Override public void addGameRecord(IGameRecord record)
    {
      gameRecords.add(record);
      XML xmlRecord = xmlStats.addChild(XML_RECORD);
      xmlRecord.setInt(XML_LEVEL_ACHIEVED, record.getLevelAchieved());
      xmlRecord.setInt(XML_SCORE_ACHIEVED, record.getScoreAchieved());
      xmlRecord.setInt(XML_TIME_PLAYED, record.getTimePlayed());
      xmlRecord.setFloat(XML_AVERAGE_SPEED, record.getAverageSpeed());
      xmlRecord.setInt(XML_COINS_COLLECTED, record.getCoinsCollected());
      xmlRecord.setString(XML_DATE, Long.toString(record.getDate()));
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }
    
    @Override public void clear()
    {
      gameRecords.clear();
      
      for (String childName : xmlStats.listChildren())
      {
        xmlStats.removeChild(xmlStats.getChild(childName));
      }
      
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public class ByLevelAchievedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getLevelAchieved(), g2.getLevelAchieved());
      }
    }

    public class ByScoreAchievedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getScoreAchieved(), g2.getScoreAchieved());
      }
    }

    public class ByTimePlayedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getTimePlayed(), g2.getTimePlayed());
      }
    }

    public class ByAverageSpeedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Float.compare(g1.getAverageSpeed(), g2.getAverageSpeed());
      }
    }

    public class ByCoinsCollectedComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Integer.compare(g1.getCoinsCollected(), g2.getCoinsCollected());
      }
    }

    public class ByDateComparator implements Comparator<IGameRecord>
    {
      @Override public int compare(IGameRecord g1, IGameRecord g2)
      {
        return Long.compare(g1.getDate(), g2.getDate());
      }
    }

  }
  
  //--------------------------------------------
  // CUSTOMIZE OPTIONS
  //--------------------------------------------
  public class CustomizeOptions implements ICustomizeOptions
  {
    private final String PLAYER_FILE_NAME_IN = "xml_data/player.xml";
    private final String PLAYER_FILE_NAME_OUT = "data/xml_data/player.xml";
    private final String PLATFORM_FILE_NAME_IN = "xml_data/platform.xml";
    private final String PLATFORM_FILE_NAME_OUT = "data/xml_data/platform.xml";
    private final String PLATFORM_SLIPPERY_NAME_IN = "xml_data/platform_slippery.xml";
    private final String PLATFORM_SLIPPERY_NAME_OUT = "data/xml_data/platform_slippery.xml";
    private final String PLATFORM_STICKY_NAME_IN = "xml_data/platform_sticky.xml";
    private final String PLATFORM_STICKY_NAME_OUT = "data/xml_data/platform_sticky.xml";
    private final String WALL_FILE_NAME_IN = "xml_data/wall.xml";
    private final String WALL_FILE_NAME_OUT = "data/xml_data/wall.xml";
    private final String COIN_FILE_NAME_IN = "xml_data/coin.xml";
    private final String COIN_FILE_NAME_OUT = "data/xml_data/coin.xml";
    private final String OBSTACLE_FILE_NAME_IN = "xml_data/obstacle.xml";
    private final String OBSTACLE_FILE_NAME_OUT = "data/xml_data/obstacle.xml";
    private final String MUSIC_FILE_NAME_IN = "xml_data/music_player.xml";
    private final String MUSIC_FILE_NAME_OUT = "data/xml_data/music_player.xml";
    private final String XML_CUST = "Customize";
    private final String COINS_COLLECTED = "coins_collected";
    private final String BACKGROUND = "background";
    private final String OPACITY_BACKGROUND = "opacity_bg";
    private final String ACTIVE_PLAYER_INDEX = "active_player_index";
    private final String ACTIVE_PLATFORM_INDEX = "active_platform_index";
    private final String ACTIVE_COIN_INDEX = "active_coin_index";
    private final String ACTIVE_OBSTACLE_INDEX = "active_obstacle_index";
    private final String ACTIVE_BACKGROUND_INDEX = "active_background_index";
    private final String ACTIVE_MUSIC_INDEX = "active_music_index";
    private final String CUSTOM_SETTINGS_FILE_IN = "xml_data/customize_settings_message.xml";
    private final String CUSTOM_SETTINGS_FILE_OUT = "data/xml_data/customize_settings_message.xml";
    private final String CUSTOM_PURCHASE_FILE_IN = "xml_data/customize_purchase_message.xml";
    private final String CUSTOM_PURCHASE_FILE_OUT = "data/xml_data/customize_purchase_message.xml";
    private final String ALL_PLAYERS_FILE_IN = "xml_data/player_data.xml";
    private final String ALL_PLATFORMS_FILE_IN = "xml_data/platform_data.xml";
    private final String ALL_OBSTACLES_FILE_IN = "xml_data/obstacle_data.xml";
    private final String ALL_COINS_FILE_IN = "xml_data/coin_data.xml";

    private XML xmlCust;
    private XML xmlPlayer;
    private XML xmlWall;
    private XML xmlPlatform;
    private XML xmlPlatformSlippery;
    private XML xmlPlatformSticky;
    private XML xmlCoin;
    private XML xmlObstacle;
    private XML xmlMusicPlayer;
    private XML xmlCustomSettings;
    private XML xmlCustomPurchase;

    private XML playerData;
    private XML animationData;
    private XML platformData;
    private XML platformSlipperyData;
    private XML platformStickyData;
    private XML wallData;
    private XML coinData;
    private XML obstacleData;
    private XML musicPlayerData;
    private int coinsCollected;
    private String background;
    private String opacityBackground;

    private int activePlayerIndex;
    private int activePlatformIndex;
    private int activeCoinIndex;
    private int activeObstacleIndex;
    private int activeBackgroundIndex;
    private int activeMusicIndex;

    private CustomizeOptions()
    {
      xmlCust = xmlSaveData.getChild(XML_CUST);
      xmlPlayer = loadXML(PLAYER_FILE_NAME_IN);
      xmlPlatform = loadXML(PLATFORM_FILE_NAME_IN);
      xmlPlatformSlippery = loadXML(PLATFORM_SLIPPERY_NAME_IN);
      xmlPlatformSticky = loadXML(PLATFORM_STICKY_NAME_IN);
      xmlWall = loadXML(WALL_FILE_NAME_IN);
      xmlCoin = loadXML(COIN_FILE_NAME_IN);
      xmlObstacle = loadXML(OBSTACLE_FILE_NAME_IN);
      xmlMusicPlayer = loadXML(MUSIC_FILE_NAME_IN);
      xmlCustomSettings = loadXML(CUSTOM_SETTINGS_FILE_IN);
      xmlCustomPurchase = loadXML(CUSTOM_PURCHASE_FILE_IN);

      playerData = xmlPlayer.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("SpriteSheet")[0];
      animationData = xmlPlayer.getChildren("AnimationController")[0];
      platformData = xmlPlatform.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("Image")[0];
      platformSlipperyData = xmlPlatformSlippery.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("Image")[0];
      platformStickyData = xmlPlatformSticky.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("Image")[0];
      wallData = xmlWall.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("Image")[0];
      coinData = xmlCoin.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("SpriteSheet")[0];
      obstacleData = xmlObstacle.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("SpriteSheet")[0];
      musicPlayerData = xmlMusicPlayer.getChildren("MusicPlayer")[0];
      coinsCollected = xmlCust.getInt(COINS_COLLECTED);
      background = xmlCust.getString(BACKGROUND);
      opacityBackground = xmlCust.getString(OPACITY_BACKGROUND);

      activePlayerIndex = xmlCust.getInt(ACTIVE_PLAYER_INDEX);
      activePlatformIndex = xmlCust.getInt(ACTIVE_PLATFORM_INDEX);
      activeCoinIndex = xmlCust.getInt(ACTIVE_COIN_INDEX);
      activeObstacleIndex = xmlCust.getInt(ACTIVE_OBSTACLE_INDEX);
      activeBackgroundIndex = xmlCust.getInt(ACTIVE_BACKGROUND_INDEX);
      activeMusicIndex = xmlCust.getInt(ACTIVE_MUSIC_INDEX);
    }

    public int getCoinsCollected()
    {
      return coinsCollected;
    }

    public String getBackground()
    {
      return background;
    }

    public String getOpacityBackground()
    {
      return opacityBackground;
    }

    public void setCoinsCollected(int _newCoins)
    {
      coinsCollected += _newCoins;
      xmlCust.setInt(COINS_COLLECTED, coinsCollected);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setCoinsAfterPurchase(int _price)
    {
      coinsCollected -= _price;
      xmlCust.setInt(COINS_COLLECTED, coinsCollected);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setPlayer(int _newActivePlayerIndex)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activePlayerIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActivePlayerIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activePlayerIndex = _newActivePlayerIndex;

      XML allPlayers = loadXML(ALL_PLAYERS_FILE_IN);
      XML sprite = allPlayers.getChildren("Render")[0].getChildren("SpriteSheet")[_newActivePlayerIndex];
      XML animation = allPlayers.getChildren("Render")[0].getChildren("AnimationController")[_newActivePlayerIndex];

      playerData.setString("src", sprite.getString("src"));
      playerData.setString("horzCount", sprite.getString("horzCount"));
      playerData.setString("vertCount", sprite.getString("vertCount"));
      playerData.setString("defaultCount", sprite.getString("defaultCount"));
      playerData.setString("farmeFreq", sprite.getString("farmeFreq"));
      playerData.setString("height", sprite.getString("height"));
      playerData.setString("scaleHeight", sprite.getString("scaleHeight"));
      animationData.setString("rightStart", animation.getString("rightStart"));
      animationData.setString("rightEnd", animation.getString("rightEnd"));
      animationData.setString("leftStart", animation.getString("leftStart"));
      animationData.setString("leftEnd", animation.getString("leftEnd"));
      saveXML(xmlPlayer, PLAYER_FILE_NAME_OUT);

      xmlCust.setInt("active_player_index", _newActivePlayerIndex);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setPlatform(int _newActivePlatformIndex, int _id)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activePlatformIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActivePlatformIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activePlatformIndex = _newActivePlatformIndex;

      XML allPlatforms = loadXML(ALL_PLATFORMS_FILE_IN);
      String platformSrc = allPlatforms.getChildren("Render")[0].getChildren("Sprite")[_id * 4].getChildren("Image")[0].getString("src");
      String platformSlippery = allPlatforms.getChildren("Render")[0].getChildren("Sprite")[_id * 4 + 1].getChildren("Image")[0].getString("src");
      String platformSticky = allPlatforms.getChildren("Render")[0].getChildren("Sprite")[_id * 4 + 2].getChildren("Image")[0].getString("src");
      String wallSrc = allPlatforms.getChildren("Render")[0].getChildren("Sprite")[_id * 4 + 3].getChildren("Image")[0].getString("src");

      platformData.setString("src", platformSrc);
      saveXML(xmlPlatform, PLATFORM_FILE_NAME_OUT);

      platformSlipperyData.setString("src", platformSlippery);
      saveXML(xmlPlatformSlippery, PLATFORM_SLIPPERY_NAME_OUT);

      platformStickyData.setString("src", platformSticky);
      saveXML(xmlPlatformSticky, PLATFORM_STICKY_NAME_OUT);

      wallData.setString("src", wallSrc);
      saveXML(xmlWall, WALL_FILE_NAME_OUT);

      xmlCust.setInt("active_platform_index", _newActivePlatformIndex);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setCoin(int _newActiveCoinIndex, int _id)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activeCoinIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActiveCoinIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activeCoinIndex = _newActiveCoinIndex;

      XML allCoins = loadXML(ALL_COINS_FILE_IN);
      XML sprite = allCoins.getChildren("Render")[0].getChildren("SpriteSheet")[_id];

      coinData.setString("src", sprite.getString("src"));
      coinData.setString("horzCount", sprite.getString("horzCount"));
      coinData.setString("vertCount", sprite.getString("vertCount"));
      coinData.setString("defaultCount", sprite.getString("defaultCount"));
      coinData.setString("farmeFreq", sprite.getString("farmeFreq"));
      coinData.setString("height", sprite.getString("height"));
      saveXML(xmlCoin, COIN_FILE_NAME_OUT);

      xmlCust.setInt("active_coin_index", _newActiveCoinIndex);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setObstacle(int _newActiveObstacleIndex, int _id)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activeObstacleIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActiveObstacleIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activeObstacleIndex = _newActiveObstacleIndex;

      XML allObstacles = loadXML(ALL_OBSTACLES_FILE_IN);
      XML sprite = allObstacles.getChildren("Render")[0].getChildren("SpriteSheet")[_id];

      obstacleData.setString("src", sprite.getString("src"));
      obstacleData.setString("horzCount", sprite.getString("horzCount"));
      obstacleData.setString("vertCount", sprite.getString("vertCount"));
      obstacleData.setString("defaultCount", sprite.getString("defaultCount"));
      obstacleData.setString("farmeFreq", sprite.getString("farmeFreq"));
      obstacleData.setString("height", sprite.getString("height"));
      saveXML(xmlObstacle, OBSTACLE_FILE_NAME_OUT);

      xmlCust.setInt("active_obstacle_index", _newActiveObstacleIndex);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setBackground(int _newActiveBackgroundIndex, int _id)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activeBackgroundIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActiveBackgroundIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activeBackgroundIndex = _newActiveBackgroundIndex;

      String bgSvgSrc = xmlCust.getChildren("Background")[_id].getString("bg");
      String opacitySvgSrc = xmlCust.getChildren("Background")[_id].getString("opacity_bg");

      background = bgSvgSrc;
      opacityBackground = opacitySvgSrc;

      xmlCust.setInt(ACTIVE_BACKGROUND_INDEX, _newActiveBackgroundIndex);
      xmlCust.setString(BACKGROUND, bgSvgSrc);
      xmlCust.setString(OPACITY_BACKGROUND, opacitySvgSrc);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void setMusic(int _newActiveMusicIndex, int _id)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[activeMusicIndex].setString("active", "false");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_newActiveMusicIndex].setString("active", "true");
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
      activeMusicIndex = _newActiveMusicIndex;

      String musicFile = xmlCust.getChildren("Music")[_id].getString("file");

      musicPlayerData.setString("musicFile", musicFile);
      saveXML(xmlMusicPlayer, MUSIC_FILE_NAME_OUT);

      xmlCust.setInt("active_music_index", _newActiveMusicIndex);
      xmlCust.setString("music", musicFile);
      saveXML(xmlSaveData, SAVE_DATA_FILE_NAME_OUT);
    }

    public void purchase(int _custSpriteIndex)
    {
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_custSpriteIndex].setString("unlocked", "true");
      String actualSrc = xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_custSpriteIndex].getString("actualSrc");
      xmlCustomSettings.getChildren("Render")[0].getChildren("CustomSprite")[_custSpriteIndex].getChildren("SpriteSheet")[0].setString("src", actualSrc);
      saveXML(xmlCustomSettings, CUSTOM_SETTINGS_FILE_OUT);
    }

    public void preparePurchaseScreen(int custSpriteIndex, RenderComponent renderComponent)
    {
      String actualSrc = renderComponent.getCustomSprites().get(custSpriteIndex).actualSrc;
      int horzCount = renderComponent.getCustomSprites().get(custSpriteIndex).horzCount;
      int vertCount = renderComponent.getCustomSprites().get(custSpriteIndex).vertCount;
      int defaultCount = renderComponent.getCustomSprites().get(custSpriteIndex).defaultCount;
      float frameFreq = renderComponent.getCustomSprites().get(custSpriteIndex).frameFreq;

      XML spriteData = xmlCustomPurchase.getChildren("Render")[0].getChildren("Sprite")[0].getChildren("SpriteSheet")[0];
      spriteData.setString("src", actualSrc);
      spriteData.setString("horzCount", horzCount+"");
      spriteData.setString("vertCount", vertCount+"");
      spriteData.setString("defaultCount", defaultCount+"");
      spriteData.setString("farmeFreq", frameFreq+"");
      saveXML(xmlCustomPurchase, CUSTOM_PURCHASE_FILE_OUT);
    }
  }

  //--------------------------------------------
  // CREDITS SETTINGS
  //--------------------------------------------
  public class Credits implements ICredits
  {
    private final String XML_CREDITS = "Credits";
    private final String ANONYMOUS = "anonymous";

    private XML xmlStats;
    private boolean anonymous;

    private Credits()
    {
      xmlStats = xmlSaveData.getChild(XML_CREDITS);

      anonymous = Boolean.parseBoolean(xmlStats.getString(ANONYMOUS));
    }

    @Override public boolean isAnonymous()
    {
      return anonymous;
    }
  }
  //--------------------------------------------
  // UserInformation OPTIONS
  //--------------------------------------------
  
  public class UserInformation implements IUserInformation
  {
    private String userID;
    
    private UserInformation()
    {
      //println("User Created");
    }
    
    @Override public String getUserID()
    {
      return userID;
    }
    @Override public void setSaveDataFile(String loginID)
    {
      userID = loginID;
      String newUserSavedDataIN = "xml_data/user_save_data/save_data" + loginID + ".xml";
      String newUserSavedDataOUT = "data/xml_data/user_save_data/save_data" + loginID + ".xml";
      File f = new File(dataPath(newUserSavedDataIN));
      if (!f.exists()) {
        println("File does not exist");
        saveXML(xmldefaultData, newUserSavedDataOUT);
      }
      xmlSaveData = loadXML(newUserSavedDataIN);
      SAVE_DATA_FILE_NAME_IN = newUserSavedDataIN;
      SAVE_DATA_FILE_NAME_OUT = newUserSavedDataOUT;
      reloadOptions();
    }
     @Override public void getDefaultSetting()
    {
      
    }
  }
}

public class GameRecordViewHelper implements IGameRecordViewHelper
{
  private final String EMPTY_VALUE = "---";
  private IGameRecord gameRecord;

  public GameRecordViewHelper(IGameRecord _gameRecord)
  {
    gameRecord = _gameRecord;
  }

  @Override public String getLevelAchieved()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getLevelAchieved());
  }

  @Override public String getScoreAchieved()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getScoreAchieved());
  }

  @Override public String getTimePlayed()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;

    int milliseconds = gameRecord.getTimePlayed();
    int seconds = (milliseconds/1000) % 60;
    int minutes = milliseconds/60000;
    return String.format("%3d:%02d", minutes, seconds);
  }

  @Override public String getAverageSpeed()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return String.format("%.1f", gameRecord.getAverageSpeed());
  }

  @Override public String getCoinsCollected()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;
    else
      return Integer.toString(gameRecord.getCoinsCollected());
  } 

  @Override public String getDate()
  {
    if (gameRecord == null)
      return EMPTY_VALUE;

    SimpleDateFormat dateFormatter = new SimpleDateFormat("MMM dd, ''yy");
    return dateFormatter.format(new Date(gameRecord.getDate()));
  }
}
