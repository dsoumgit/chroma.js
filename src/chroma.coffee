###*
    chroma.js - a neat JS lib for color conversions
    Copyright (C) 2011  Gregor Aisch

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

root = (exports ? this)	
chroma = root.chroma ?= {}


class Color
	###
	data type for colors
	
	eg.
	new Color() // white
	new Color(120,.8,.5) // defaults to hsl color
	new Color([120,.8,.5]) // this also works
	new Color(255,100,50,'rgb') //  color using RGB
	new Color('#ff0000') // or hex value
	
	###
	constructor: (x,y,z,m) ->
		me = @
		
		if not x? and not y? and not z? and not m?
			x = [255,0,255]
			
		if type(x) == "array" and x.length == 3
			m ?= y
			[x,y,z] = x
		
		if type(x) == "string"
			m = 'hex'
		else 
			m ?= 'rgb'

		if m == 'rgb'
			me.rgb = [x,y,z]
		else if m == 'hsl'
			me.rgb = Color.hsl2rgb(x,y,z)
		else if m == 'hsv'
			me.rgb = Color.hsv2rgb(x,y,z)
		else if m == 'hex'
			me.rgb = Color.hex2rgb(x)
		else if m == 'lab'
			me.rgb = Color.lab2rgb(x,y,z)
		else if m == 'cls'
			me.rgb = Color.cls2rgb(x,y,z)
		
	hex: ->
		Color.rgb2hex(@rgb)
		
	toString: ->
		@hex()
		
	hsl: ->
		Color.rgb2hsl(@rgb)
		
	hsv: ->
		Color.rgb2hsv(@rgb)
		
	lab: ->
		Color.rgb2lab(@rgb)
		
	interpolate: (f, col, m) ->
		###
		interpolates between colors
		###
		me = @
		m ?= 'rgb'
		col = new Color(col) if type(col) == "string"
		
		if m == 'hsl' or m == 'hsv' # or hsb..
			if m == 'hsl'
				xyz0 = me.hsl()
				xyz1 = col.hsl()
			else if m == 'hsv'
				xyz0 = me.hsv()
				xyz1 = col.hsv()
		
			[hue0, sat0, lbv0] = xyz0
			[hue1, sat1, lbv1] = xyz1
								
			if not isNaN(hue0) and not isNaN(hue1)
				if hue1 > hue0 and hue1 - hue0 > 180
					dh = hue1-(hue0+360)
				else if hue1 < hue0 and hue0 - hue1 > 180
					dh = hue1+360-hue0
				else
					dh = hue1 - hue0
				hue = hue0+f*dh
			else if not isNaN(hue0)
				hue = hue0
				sat = sat0 if lbv1 == 1 or lbv1 == 0
			else if not isNaN(hue1)
				hue = hue1
				sat = sat1 if lbv0 == 1 or lbv0 == 0
			else
				hue = undefined
								
			sat ?= sat0 + f*(sat1 - sat0)

			lbv = lbv0 + f*(lbv1-lbv0)
		
			new Color(hue, sat, lbv, m)
			
		else if m == 'rgb'
			xyz0 = me.rgb
			xyz1 = col.rgb
			new Color(xyz0[0]+f*(xyz1[0]-xyz0[0]), xyz0[1] + f*(xyz1[1]-xyz0[1]), xyz0[2] + f*(xyz1[2]-xyz0[2]), m)
		
		else if m == 'lab'
			
		
		else
			throw "color mode "+m+" is not supported"

Color.hex2rgb = (hex) ->
	if not hex.match /^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
		throw new "wrong hex color format: "+hex
		
	if hex.length == 4 or hex.length == 7
		hex = hex.substr(1)
	if hex.length == 3
		hex = hex[1]+hex[1]+hex[2]+hex[2]+hex[3]+hex[3]
	u = parseInt(hex, 16)
	r = u >> 16
	g = u >> 8 & 0xFF
	b = u & 0xFF
	[r,g,b]
	

Color.rgb2hex = (r,g,b) ->
	if r != undefined and r.length == 3
		[r,g,b] = r
	u = r << 16 | g << 8 | b
	str = "000000" + u.toString(16).toUpperCase()
	"#" + str.substr(str.length - 6)


Color.hsv2rgb = (h,s,v) ->
	if type(h) == "array" and h.length == 3
		[h,s,l] = h
	v *= 255
	if s is 0 and isNaN(h)
		r = g = b = v
	else
		h = 0 if h is 360
		h /= 60
		i = Math.floor h
		f = h - i
		p = v * (1 - s)
		q = v * (1 - s * f)
		t = v * (1 - s * (1 - f))
		switch i
			when 0 then [r,g,b] = [v, t, p]
			when 1 then [r,g,b] = [q, v, p]
			when 2 then [r,g,b] = [p, v, t]
			when 3 then [r,g,b] = [p, q, v]
			when 4 then [r,g,b] = [t, p, v]
			when 5 then [r,g,b] = [v, p, q]	
	r = Math.round r
	g = Math.round g
	b = Math.round b
	[r, g, b]

	
Color.rgb2hsv = (r,g,b) ->
	if r != undefined and r.length == 3
		[r,g,b] = r
	min = Math.min(r, g, b)
	max = Math.max(r, g, b)
	delta = max - min
	v = max / 255.0
	s = delta / max
	if s is 0
		h = undefined
		s = 0
	else
		if r is max then h = (g - b) / delta
		if g is max then h = 2+(b - r) / delta
		if b is max then h = 4+(r - g) / delta
		h *= 60;
		if h < 0 then h += 360
	[h, s, v]


Color.hsl2rgb = (h,s,l) ->
	if h != undefined and h.length == 3
		[h,s,l] = h
	if s == 0
		r = g = b = l*255
	else
		t3 = [0,0,0]
		c = [0,0,0]
		t2 = if l < 0.5 then l * (1+s) else l+s-l*s
		t1 = 2 * l - t2
		h /= 360
		t3[0] = h + 1/3
		t3[1] = h
		t3[2] = h - 1/3
		for i in [0..2]
			t3[i] += 1 if t3[i] < 0
			t3[i] -= 1 if t3[i] > 1
			if 6 * t3[i] < 1
				c[i] = t1 + (t2 - t1) * 6 * t3[i]
			else if 2 * t3[i] < 1
				c[i] = t2
			else if 3 * t3[i] < 2
				c[i] = t1 + (t2 - t1) * ((2 / 3) - t3[i]) * 6
			else 
				c[i] = t1
		[r,g,b] = [Math.round(c[0]*255),Math.round(c[1]*255),Math.round(c[2]*255)]
	[r,g,b]	


Color.rgb2hsl = (r,g,b) ->
	if r != undefined and r.length == 3
		[r,g,b] = r
	r /= 255
	g /= 255
	b /= 255
	min = Math.min(r, g, b)
	max = Math.max(r, g, b)

	l = (max + min) / 2
	
	if max == min
		s = 0
		h = undefined
	else
		s = if l < 0.5 then (max - min) / (max + min) else (max - min) / (2 - max - min)

	if r == max then h = (g - b) / (max - min)
	else if (g == max) then h = 2 + (b - r) / (max - min)
	else if (b == max) then h = 4 + (r - g) / (max - min)
	
	h *= 60;
	h += 360 if h < 0
	[h,s,l]

#
# L*a*b* scale by David Dalrymple	
# http://davidad.net/colorviz/	
#
Color.lab2xyz = (l,a,b) ->
	###
	Convert from L*a*b* doubles to XYZ doubles
	Formulas drawn from http://en.wikipedia.org/wiki/Lab_color_spaces
	###
	if type(l) == "array" and l.length == 3
		[l,a,b] = l

	finv = (t) ->
		if t > (6.0/29.0) then t*t*t else 3*(6.0/29.0)*(6.0/29.0)*(t-4.0/29.0)
	sl = (l+0.16) / 1.16
	ill = [0.96421, 1.00000, 0.82519]
	y = ill[1] * finv(sl)
	x = ill[0] * finv(sl + (a/5.0))
	z = ill[2] * finv(sl - (b/2.0))
	[x,y,z]
	
Color.xyz2rgb = (x,y,z) ->
	###
	Convert from XYZ doubles to sRGB bytes
	Formulas drawn from http://en.wikipedia.org/wiki/Srgb
	###
	if type(x) == "array" and x.length == 3
		[x,y,z] = x
	
	rl =  3.2406*x - 1.5372*y - 0.4986*z
	gl = -0.9689*x + 1.8758*y + 0.0415*z
	bl =  0.0557*x - 0.2040*y + 1.0570*z
	clip = Math.min(rl,gl,bl) < -0.001 || Math.max(rl,gl,bl) > 1.001
	if clip
		rl = if rl<0.0 then 0.0 else if rl>1.0 then 1.0 else rl
		gl = if gl<0.0 then 0.0 else if gl>1.0 then 1.0 else gl
		bl = if bl<0.0 then 0.0 else if bl>1.0 then 1.0 else bl
	
	# Uncomment the below to detect clipping by making clipped zones red.
	if clip 
		[rl,gl,bl] = [undefined,undefined,undefined]
		
	correct = (cl) ->
		a = 0.055
		if cl<=0.0031308 then 12.92*cl else (1+a)*Math.pow(cl,1/2.4)-a
	
	r = Math.round 255.0*correct(rl)
	g = Math.round 255.0*correct(gl)
	b = Math.round 255.0*correct(bl)
	 
	[r,g,b]
	
Color.lab2rgb = (l,a,b) ->
	###
	Convert from LAB doubles to sRGB bytes 
	(just composing the above transforms)
	###
	if l != undefined and l.length == 3
		[l,a,b] = l

	if l != undefined and l.length == 3
		[l,a,b] = l
	[x,y,z] = Color.lab2xyz(l,a,b)
	Color.xyz2rgb(x,y,z)
	
Color.cls2rgb = (c,l,s=1) ->
	if c != undefined and c.length == 3
		[c,l,s] = c
		
	TAU = 6.283185307179586476925287
	L = l*0.61+0.09 # L of L*a*b*
	angle = TAU/6.0-c*TAU
	r = (l*0.311+0.125)*s # ~chroma
	a = Math.sin(angle)*r
	b = Math.cos(angle)*r
	Color.lab2rgb(L,a,b)
	
Color.rgb2xyz = (r,g,b) ->
	if r != undefined and r.length == 3
		[r,g,b] = r
	
	correct = (c) ->
		a = 0.055
		if c <= 0.04045 then c/12.92 else Math.pow((c+a)/(1+a), 2.4)	
	
	rl = correct(r/255.0)
	gl = correct(g/255.0)
	bl = correct(b/255.0)
	
	x = 0.4124 * rl + 0.3576 * gl + 0.1805 * bl
	y = 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
	z = 0.0193 * rl + 0.1192 * gl + 0.9505 * bl
	[x,y,z]
	
Color.xyz2lab = (x,y,z) ->
	# 6500K color templerature
	if x != undefined and x.length == 3
		[x,y,z] = x
		
	ill = [0.96421, 1.00000, 0.82519]	
	f = (t) ->
		if t > Math.pow(6.0/29.0,3) then Math.pow(t, 1/3) else (1/3)*(29/6)*(29/6)*t+4.0/29.0
	l = 1.16 * f(y/ill[1]) - 0.16
	a = 5 * (f(x/ill[0]) - f(y/ill[1]))
	b = 2 * (f(y/ill[1]) - f(z/ill[2])) 
	[l,a,b]
	
Color.rgb2lab = (r,g,b) ->
	if r != undefined and r.length == 3
		[r,g,b] = r
	[x,y,z] = Color.rgb2xyz(r,g,b)
	Color.xyz2lab(x,y,z)




chroma.Color = Color	

#
# static constructors
#

chroma.hsl = (h,s,l) ->
	new Color(h,s,l,'hsl')

chroma.hsv = (h,s,v) ->
	new Color(h,s,v,'hsv')

chroma.rgb = (r,g,b) ->
	new Color(r,g,b,'rgb')

chroma.hex = (x) ->
	new Color(x)
	
chroma.lab = (l,a,b) ->
	new Color(l,a,b,'lab')

chroma.cls = (c,l,s) ->
	new Color(c,l,s,'cls')
	
	
	
	
	

class ColorScale
	###
	base class for color scales
	###
	constructor: (colors, positions, mode, nacol='#cccccc') ->
		me = @
		for c in [0..colors.length-1]
			colors[c] = new Color(colors[c]) if typeof(colors[c]) == "string"
		me.colors = colors
		me.pos = positions
		me.mode = mode
		me.nacol = nacol
		me
		
	
	getColor: (value) ->
		me = @
		if isNaN(value) then return me.nacol
		value = me.classifyValue value	
		f = f0 = (value - me.min) / (me.max - me.min)
		f = Math.min(1, Math.max(0, f))
		for i in [0..me.pos.length-1]
			p = me.pos[i]
			if f <= p
				col = me.colors[i]
				break			
			if f >= p and i == me.pos.length-1
				col = me.colors[i]
				break
			if f > p and f < me.pos[i+1]
				f = (f-p)/(me.pos[i+1]-p)
				col = me.colors[i].interpolate(f, me.colors[i+1], me.mode)
				break
		col
	
	setClasses: (numClasses = 5, method='equalinterval', limits = []) ->
		###
		# use this if you want to display a limited number of data classes
		# possible methods are "equalinterval", "quantiles", "custom"
		###
		me = @
		me.classMethod = method
		me.numClasses = numClasses
		me.classLimits = limits
		me
			
	parseData: (data, data_col) ->
		self = @
		min = Number.MAX_VALUE
		max = Number.MAX_VALUE*-1
		sum = 0
		values = []
		for id,row of data
			val = if data_col? then row[data_col] else row
			if not self.validValue(val) 
				continue
			min = Math.min(min, val)
			max = Math.max(max, val)
			values.push(val)
			sum += val
		values = values.sort()
		if values.length % 2 == 1
			self.median = values[Math.floor(values.length*0.5)]
		else
			h = values.length*0.5
			self.median = values[h-1]*0.5 + values[h]*0.5
		self.values = values
		self.mean = sum/values.length
		self.min = min
		self.max = max
		
		method = self.classMethod
		num = self.numClasses
		limits = self.classLimits
		if method?
			if method == "equalinterval"
				for i in [1..num-1]
					limits.push min+(i/num)*(max-min) 
			else if method == "quantiles"
				for i in [1..num-1] 
					p = values.length * i/num
					pb = Math.floor(p)
					if pb == p
						limits.push values[pb] 
					else # p > pb 
						pr = p - pb
						limits.push values[pb]*pr + values[pb+1]*(1-pr)
			limits.unshift(min)
			limits.push(max)
		return
	
	
	
	classifyValue: (value) ->
		self = @ 
		limits = self.classLimits
		if limits?
			n = limits.length -1
			i = self.getClass(value)
			value = limits[i] + (limits[i+1] - limits[i]) * 0.5			
			minc = limits[0] + (limits[1]-limits[0])*0.3
			maxc = limits[n-1] + (limits[n]-limits[n-1])*0.7
			value = self.min + ((value - minc) / (maxc-minc)) * (self.max - self.min)
		value
		
		
	getClass: (value) ->
		self = @ 
		limits = self.classLimits
		if limits?
			n = limits.length-1
			i = 0
			while i < n and value >= limits[i]
				i++
			return i-1
		return undefined
		
		
	validValue: (value) ->
		not isNaN(value)



class Ramp extends ColorScale
	
	constructor: (col0='#fe0000', col1='#feeeee', mode='hsl') ->
		super [col0,col1], [0,1], mode

chroma.Ramp = Ramp


class Diverging extends ColorScale
	
	constructor: (col0='#d73027', col1='#ffffbf', col2='#1E6189', center='mean', mode='hsl') ->
		me=@
		me.mode = mode
		me.center = center
		super [col0,col1,col2], [0,.5,1], mode
	
	parseData: (data, data_col) ->
		super data, data_col
		me = @
		c = me.center
		if c == 'median'
			c = me.median
		else if c == 'mean'
			c = me.mean	
		me.pos[1] = (c-me.min)/(me.max-me.min)
	

chroma.Diverging = Diverging


class Categories extends ColorScale

	constructor: (colors) ->
		# colors: dictionary of id: colors
		me = @
		me.colors = colors
		
	parseData: (data, data_col) ->
		# nothing to do here..
		
	getColor: (value) ->
		me = @
		if me.colors.hasOwnProperty value
			return me.colors[value]
		else
			return '#cccccc'
	
	validValue: (value) ->
		@colors.hasOwnProperty value
		
chroma.Categories = Categories


class CSSColors extends ColorScale

	constructor: (name) ->
		me = @
		me.name = name			
		me.setClasses(7)
		me
		
	getColor: (value) ->
		me = @
		c = me.getClass(value)
		me.name + ' l'+me.numClasses+' c'+c

chroma.CSSColors = CSSColors


# some pre-defined color scales:
chroma.scales ?= {}

chroma.scales.cool = ->
	new Ramp(chroma.hsl(180,1,.9), chroma.hsl(250,.7,.4))

chroma.scales.hot = ->
	new ColorScale(['#000000','#ff0000','#ffff00','#ffffff'],[0,.25,.75,1],'rgb')
	
chroma.scales.BlWhOr = ->
	new Diverging(chroma.hsl(30,1,.55),'#ffffff', new Color(220,1,.55))

chroma.scales.GrWhPu = ->
	new Diverging(chroma.hsl(120,.8,.4),'#ffffff', new Color(280,.8,.4))


