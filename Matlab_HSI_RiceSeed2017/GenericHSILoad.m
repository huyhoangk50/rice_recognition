
function [I,info]=GenericHSILoad(filename)
tic;
filename
info = read_envihdr([filename '.hdr']);

switch info.data_type
    case {1}
        format = 'uint8';
        bits = 1;
    case {2}
        format= 'int16';
        bits = 2;
    case{3}
        format= 'int32';
        bits = 4;
    case {4}
        format= 'single';
        bits = 4;
    case {5}
        format= 'double';
        bits = 8;
    case {6}
        disp('>> Sorry, Complex (2x32 bits)data currently not supported');
        disp('>> Importing as double-precision instead');
        format= 'double';
    case {9}
        error('Sorry, double-precision complex (2x64 bits) data currently not supported');
    case {12}
        format= 'uint16';
        bits = 2;
    case {13}
        format= 'uint32';
    case {14}
        format= 'int64';
    case {15}
        format= 'uint64';
    otherwise
        error(['File type number: ',num2str(dtype),' not supported']);
end
    

%I = multibandread([filename '.raw'], [info.lines info.samples info.bands], format, info.header_offset, info.interleave, 'ieee-le');
if exist([filename '.raw'],'file')==2
    ext='.raw';
elseif exist([filename '.bin'],'file')==2
    ext='.bin';
elseif exist([filename '.hyspex'],'file')==2
    ext='.hyspex';
elseif exist([filename '.mj2'],'file')==2
    ext='.mj2';
    [I,~] = MJ2kLoad(filename);
    return
end
fid=fopen([filename ext],'r');

I = zeros([info.lines,info.samples,info.bands],format);
A = size(I);
% fprintf('I is %d by %d by %d \n', A);

fseek(fid, info.header_offset, 'bof');
switch info.interleave
    case 'bil'
        ReadLength = info.lines;
    case 'bip'
        ReadLength = info.lines;
    case 'bsq'
        ReadLength = info.bands;
end
CurFrame=0;
for i=1:ReadLength
    CurFrame=CurFrame+1;
%     fprintf('Frame %d of %d \n', i,ReadLength);
    switch info.interleave
        case 'bil'
                TMP =  fread(fid, [info.samples,info.bands],format);
                I(CurFrame,:,:) = TMP;
        case 'bip'
                TMP =  fread(fid, [info.bands,info.samples],format)';
                %fprintf('TMP is %d by %d by %d \n', size(TMP));
                I(CurFrame,:,:) = TMP;
        case 'bsq'
                TMP =  fread(fid, [info.samples,info.lines],format)';
                %fprintf('TMP is %d by %d by %d \n', size(TMP));
                I(:,:,CurFrame) = TMP;
    end

end
fclose(fid);
% fprintf('Hypercube read took approx. %f seconds \n', toc);
%fprintf('info.header_offset %d \n', info.header_offset);

