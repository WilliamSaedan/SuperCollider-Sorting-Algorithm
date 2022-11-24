s.boot;
(
Window.closeAll;

~elementWidth = 20;
~padding = 10;
~width = 800;
~height = 700;

~animSpeed = 1; // Separate from framerate -- determines how many steps the sorting algorithm takes per frame

~arr = Array.fill((~width/~elementWidth)+1, {arg i; ((i+1)/(~width/~elementWidth))*~height});
~arr = ~arr.scramble;

~baseFreq = 50;
~modulateFreq = 300;
SynthDef(\sawping, { |freq = 440, amp = 0.2, sustain = 1, out|
    var sig;
    sig = Saw.ar(freq, amp) * EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;

w = Window("Sorting",Rect(1000,250,(~width+(~padding*2)),(~height+(~padding*2))))
.front
.alwaysOnTop_(true);

u = UserView(w, Rect(0, 0, (~width+(~padding*2)), (~height+(~padding*2))));
u.animate = true;
u.frameRate = 60;
u.background = Color.white;

~bubbleSort = Routine { |arr|
	var len = arr.size - 1;
	Routine {
		len.do { |i|
			Routine {
				(len - i).do { |j|
					Synth(\sawping, [freq: (~baseFreq + (~modulateFreq * (arr[j])/~height)), amp: 0.05, sustain: (0.08/~animSpeed)]);
					if ((arr[j] > arr[j+1]), {
						arr = arr.swap(j,(j+1));
					});
					arr.yield;
				}
			}.embedInStream;
			arr.yield;
		};
	}.embedInStream;
	arr.yield;
};

u.drawFunc = {
	Pen.use {
		Pen.width = ~elementWidth;
		~arr.size.do {|i|
			Pen.beginPath;
			Pen.moveTo(Point(~padding + (i * ~elementWidth), ~height + ~padding - ~arr[i]));
			Pen.lineTo(Point(~padding + (i * ~elementWidth), ~height + ~padding));
			Pen.strokeColor = Color.hsv([0.999,~arr[i]/(~height)].minItem,1,1,1);
			Pen.stroke;
		};
		~animSpeed.do{ var temp;
			temp = ~bubbleSort.value(~arr);
			if ((temp != nil), {
				~arr = temp;
			});
		};
	};
};
)
s.free;