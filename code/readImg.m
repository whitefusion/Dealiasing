%[data,header]=readImg(fName,framesToRead)
%
%-fName is the base file name for the (header,binary) pair of files. Can
%   include the .hdr or .img extension. 
%-framesToRead is optional. If provided, it is assumed to be an array
%   containing the indices of frames to be read. Any repeatitions are 
%   removed from the array.
%
function [data,header]=readImg(fName,varargin)

HDR_EXT='.hdr';
BIN_EXT='.img';

if((length(fName)>3)&&(strcmp(fName((end-3):end),HDR_EXT)||(strcmp(fName((end-3):end),BIN_EXT))))
    fName=fName(1:(end-4));
end;

fNameHdr=[fName,HDR_EXT];
fNameBin=[fName,BIN_EXT];

fHandleHdr=fopen(fNameHdr,'rt');
if(fHandleHdr==-1)
    disp(['Couldn''t open ',fNameHdr]);
    data=zeros([0 0]);
    return;
end;

fHandleBin=fopen(fNameBin,'r');
if(fHandleBin==-1)
    disp(['Couldn''t open ',fNameBin]);
    data=zeros([0 0]);
    return;
end;

header=textscan(fHandleHdr,'%s=%s','CommentStyle','%');
paramNames=header{1}; paramVals=header{2}; 

isAcquisition=find(strcmp('Acquisition_format',paramNames),1);
isProcessed=find(strcmp('Proc_format',paramNames),1);
isReconstructed=find(strcmp('Recon_format',paramNames),1);

if(~isAcquisition)
    disp('Header has to start with acq. data..');
    data=zeros([0 0]);
    return;
end;

%this should always be present:
indU=find(strcmp('Panel_nu',paramNames),1);
indV=find(strcmp('Panel_nv',paramNames),1);
indNF=find(strcmp('Acquisition_frames',paramNames),1);
indFmt=find(strcmp('Acquisition_format',paramNames),1);

%this will be updated if there was further processing:
sizeU=str2double(paramVals{indU});
sizeV=str2double(paramVals{indV});
numFrames=str2double(paramVals{indNF});

if(isProcessed)
    indAngBin=find(strcmp('Proc_angular_binning',paramNames),1);
    indUVBin=find(strcmp('Proc_binning',paramNames),1);
    indFmt=find(strcmp('Proc_format',paramNames),1);
    
    stringUVbin=paramVals{indUVBin};
    indX=strfind(stringUVbin,'x');
    if(length(indX)~=1)
        disp('Wrong proj. binning parameter..');
        data=zeros([0 0]);
        return;
    end;
    
    binU=str2double(stringUVbin(1:(indX-1)));
    binV=str2double(stringUVbin((indX+1):end));
    binAngle=str2double(paramVals{indAngBin});   
    
    sizeU=sizeU/binU;
    sizeV=sizeV/binV;
    numFrames=numFrames/binAngle;
end;

if(isReconstructed)
    indXSize=find(strcmp('Volume_nx',paramNames),1);
    indYSize=find(strcmp('Volume_ny',paramNames),1);
    indZSize=find(strcmp('Volume_nz',paramNames),1);
    indFmt=find(strcmp('Recon_format',paramNames),1);
    
    sizeU=str2double(paramVals{indXSize});
    sizeV=str2double(paramVals{indYSize});
    numFrames=str2double(paramVals{indZSize});
end;

%use the format string corresponding to the file type:
fmt=paramVals{indFmt};

if(isempty(varargin))
    framesToRead=1:numFrames;
    readAll=1;
else
    framesToRead=varargin{1};
    framesToRead=unique(framesToRead);
    framesToRead=sort(framesToRead);
    if((framesToRead(end)>numFrames)||(framesToRead(1)<1))
        disp('Requested frames out of available range..');
        data=zeros([0 0]);
        return;
    end;
    readAll=0;
end;
numFramesToRead=length(framesToRead);

data=zeros([sizeV,sizeU,numFramesToRead],fmt);
fmt=[fmt,'=>',fmt];

if(numFramesToRead==1)&&((strcmp(fmt,'uint16=>uint16'))||(strcmp(fmt,'single=>single')))      
%cannot find a function returning num of bytes per data format, so starting with the essentials:    
    if(strcmp(fmt,'uint16=>uint16'))
        fseek(fHandleBin,(framesToRead(1)-1)*sizeU*sizeV*2,'bof');
    elseif(strcmp(fmt,'single=>single'))
        fseek(fHandleBin,(framesToRead(1)-1)*sizeU*sizeV*4,'bof');
    end;
    data=fread(fHandleBin,[sizeU,sizeV],fmt);
    if(isReconstructed)
        data=flipud(data');
    else
        data=data';
    end;
    
else
    dataIndex=1;
    for frameIndex=1:numFrames
        dummy=fread(fHandleBin,[sizeU,sizeV],fmt);
        
        if(readAll)
            if(mod(frameIndex,50)==0)
                disp(['Frame: ',num2str(frameIndex)]);
            end;    
            if(isReconstructed)
                data(:,:,frameIndex)=flipud(dummy');
            else
                data(:,:,frameIndex)=dummy';
            end;
        else
            if(frameIndex==framesToRead(dataIndex))
                if mod(frameIndex, 50)==0
                disp(['Frame: ',num2str(frameIndex)]);   
                end
                if(isReconstructed)
                    data(:,:,dataIndex)=flipud(dummy');
                else
                    data(:,:,dataIndex)=dummy';
                end;                
                dataIndex=dataIndex+1;
                if(dataIndex>numFramesToRead)
                    break;
                end;
            end;
        end;
        
    end;
end;

fclose(fHandleHdr);
fclose(fHandleBin);