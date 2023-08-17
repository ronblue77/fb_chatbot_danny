'~ #include "bass.bi"


'' Call this once at the beginning of the program
If (BASS_GetVersion() < MAKELONG(2,2)) Then
    Print "BASS version 2.2 or above required!"
    End 1
End If

If (BASS_Init(-1, 44100, 0, 0, 0) = 0) Then
    Print "Could not initialize BASS"
    End 1
End If

dim shared as HMUSIC g_BackgroundMusic


sub stopMusic( music as HMUSIC = NULL )
  if music = NULL then music = g_BackgroundMusic
  if music then BASS_ChannelStop( music )
end sub

sub freeMusic( music as HMUSIC = NULL )
  if music = NULL then music = g_BackgroundMusic : g_BackgroundMusic = NULL
  if music then BASS_MusicFree( music )  
end sub

function playMusic( soundfile as string ) as HMUSIC
  if g_BackgroundmUsic then 
  	stopMusic(g_BackgroundMusic)
  	freeMusic(g_BackgroundMusic)
  	g_BackgroundMusic = NULL
  EndIf
  var music = BASS_StreamCreateFile( 0, strptr( soundfile ), 0, 0, BASS_SAMPLE_LOOP )  
  if music then 
    g_BackgroundMusic = music
	BASS_ChannelPlay( music, 0 )
  end if
  return music
end Function

