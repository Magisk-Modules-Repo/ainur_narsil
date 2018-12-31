# Put sepolicy statements here
# Example: allow { audioserver mediaserver } audioserver_tmpfs file { read write open }
allow { audioserver mediaserver } dts_data_file dir { read execute open search getattr associate }
allow audioserver labeledfs filesystem associate
allow hal_audio_default dts_data_file { read write open setattr add_name create remove_name unlink execute}
