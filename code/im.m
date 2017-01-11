
function [imhh,txhh,lnhh]=im(A,varargin)
% [imh,txh,lnh]=IM(A,'name1',val1,...) - Displays an image of the stack of
%     2D images in 3-dimensional array A.  Optionally returns image, test, 
%     and line handles.
%
% Can specify plot properties in command:
%      NAME,VAL          Default   Function
%     ===========================================================
%     'nrows',num        square    Force a given number of rows
%     'ncols',num        square    Force a given number of columns
%     'drawlines',[0|1]   on=1     Binary flag for drawing line separators
%     'linecol',color    [0 1 1]   Line Color
%     'labelslice',[0|1]  on=1     Binary flag to label each slice
%     'textcol',color    [0 1 1]   Label color
%     'scaleslice',[0|1]  off=0    Scale each slice 0..1
%

% Web Stayman, January 1999.
% Note - not tested for nx =/= ny

labelslice = 1;
drawlines  = 1;
scaleslice = 0;
nrows      = NaN;
ncols      = NaN;
textcol    = [1 1 0];
linecol    = [1 1 0];

if iscell(A),
	nc = prod(size(A));
	sz = zeros(0,2);
	for j=1:nc,
		nsz = size(A{j});
		if length(nsz)~=2,
			error('All cells must be 2D');
		end
		sz = [sz; nsz];
	end
	sz = max(sz,[],1);
	B = A; A = zeros(sz(1),sz(2),nc);
	for j=1:nc,
		img = B{j};
		[nx,ny]=size(img);
		A(1:nx,1:ny,j) = img;
	end
	clear B;
end

Adat = whos('A');
if ~strcmp(Adat.class,'double'), A = double(A); end

if length(find(~isreal(A))),
	A = real(A);
	disp('Displaying real part only');
end

[nx,ny,nz]=size(A);

if nz==1,
	labelslice = 0; drawlines = 0;
end

% USER OVERRIDES
for j=1:length(varargin)/2,
	if iscell(varargin{j*2}),
		eval(['clear ',varargin{j*2-1},';']);
		for k=1:length(varargin{j*2}),
			disp([varargin{j*2-1} '{',num2str(k),'} = ''' varargin{j*2}{k} ''';']);
			eval([varargin{j*2-1} '{',num2str(k),'} = ''' varargin{j*2}{k} ''';']);
		end
	else
		eval([varargin{j*2-1} ' = ' mat2str(varargin{j*2}) ';']);
	end
end

if isnan(ncols),
	if isnan(nrows),
		if nz==1,
			ncols = 1;
		else 
			ncols = ceil(sqrt(nx*ny*nz)/ny);
		end
	else
		ncols = ceil(nz/nrows);
	end
end
if isnan(nrows),
	nrows = ceil(nz/ncols);
end
if nrows<1, disp('Error in number of rows'); return; end
if ncols<1, disp('Error in number of cols'); return; end

dx = ncols;
dy = nrows;
B = zeros(nx*dy,ny*dx);

if scaleslice,
	for i=1:nz,
		tmp = A(:,:,i);
		tmp = tmp-min(tmp(:));
		tmp = tmp/max(tmp(:));
		B( (1:nx)+(ceil(i/dx)-1)*nx, (1:ny)+mod(i-1,dx)*ny ) = tmp;
	end
else
	B = B+min(A(:));
	for i=1:nz,
		B( (1:nx)+(ceil(i/dx)-1)*nx, (1:ny)+mod(i-1,dx)*ny ) = A(:,:,i);
	end
end
imh = imagesc(B); axis image;
txh = [];
if length(labelslice)==1,
	if labelslice,
	for i=1:nz,
		y=(ceil(i/dx)-1)*nx; x=mod(i-1,dx)*ny;
		h=text(x+ny/15,y+nx/10,sprintf('%d',i)); txh=[txh; h];
		set(h,'Color',textcol);
	end
	end
else
	if length(labelslice)~=nz,
		error('Labelslice labels wrong size'); return
	end
	if iscell(labelslice)
		for i=1:nz,
			y=(ceil(i/dx)-1)*nx; x=mod(i-1,dx)*ny;
			h=text(x+ny/15,y+nx/10,labelslice{i}); txh=[txh; h];
			set(h,'Color',textcol);
		end
	else
		for i=1:nz,
			y=(ceil(i/dx)-1)*nx; x=mod(i-1,dx)*ny;
			h=text(x+ny/15,y+nx/10,sprintf('%d',labelslice(i))); txh=[txh; h];
			set(h,'Color',textcol);
		end
	end
end
lnh = [];
if drawlines,
for i=(nz+1):dx*dy,
	x = mod(i-1,dx)*ny; y = (ceil(i/dx)-1)*nx;
	h=line([x;x+ny]+0.5,[y;y+nx]+0.5); set(h,'Color',linecol); lnh=[lnh h];
	h=line([x+ny;x]+0.5,[y;y+nx]+0.5); set(h,'Color',linecol); lnh=[lnh h];
end
for i=1:dy-1,
	h=line([0;ny*dx]+0.5,[nx*i;nx*i]+0.5); set(h,'Color',linecol); lnh=[lnh h];
end
for i=1:dx-1,
        h=line([ny*i;ny*i]+0.5,[0;nx*dy]+0.5); set(h,'Color',linecol); lnh=[lnh h];
end
end

zh = zoom;
set(zh,'ActionPreCallback',@myprecallback);
set(zh,'ActionPostCallback',@mypostcallback);
set(zh,'Enable','on');
set(gca,'UserData',[nx ny nz]);
mypostcallback;
zoom off;

if nargout>0,
	imhh = imh; txhh = txh; lnhh = lnh;
end

end

    function myprecallback(obj,evd)
%    disp('A zoom is about to occur.');
	end
 
    function mypostcallback(obj,evd)
	nxyz=get(gca,'UserData');
%	set(gca,'XTickLabel',num2str(mod(get(gca,'XTick'),nxyz(2))'));
%	set(gca,'YTickLabel',num2str(mod(get(gca,'YTick'),nxyz(1))'));
	end
 

