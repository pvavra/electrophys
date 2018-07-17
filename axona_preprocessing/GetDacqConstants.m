% CONSTANTS BASED ON DacqUSBFileFormat.pdf
SAMPLING_FREQUENCY = 48000; % in Hz
NR_OF_BYTES_PER_PACKET = 432;
NR_OF_BYTES_FOR_HEADER = 32;
NR_OF_BYTES_FOR_DATA = 384;
NR_OF_BYTES_FOR_TAIL = 16;
NR_OF_CHANNELS_PER_SAMPLE = 64; 
NR_OF_BYTES_PER_DATA_CHANNEL = 2;
nSamplesPerPackage = NR_OF_BYTES_FOR_DATA / (NR_OF_BYTES_PER_DATA_CHANNEL * NR_OF_CHANNELS_PER_SAMPLE);