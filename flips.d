


ulong getFlips (ulong m, ulong astones, ulong tstones) {
            ulong flips;
            ulong flood;
            ulong gen;
            ulong pro;
  
            flips = flood = gen = 0;
            gen = m;
            pro = tstones & 0xfefefefefefefe00;
            while (gen) { 
                flood |= gen;
                gen = ((gen << 9) & pro);
            };
            if ((flood << 9) & (astones & 0xfefefefefefefe00)) {
                flips |= flood ^ m;
            };

            flood = 0;
            gen = m;
            pro = tstones & 0xfefefefefefefefe;
            while (gen) {
                flood |= gen;
                gen = ((gen << 1) & pro);
            };
            if ((flood << 1) & (astones & 0xfefefefefefefefe )) {
               flips |= flood ^ m;
            };
            
            flood = 0;
            gen = m;
            pro = tstones & 0x00fefefefefefefe;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 7) & pro);
            };
            if ((flood >> 7) & (astones & 0x00fefefefefefefe )) {
               flips |= flood ^ m;
            };

            flood = 0;
            gen = m;
            pro = tstones & 0x00ffffffffffffff;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 8) & pro);
            };
            if ((flood >> 8) & (astones & 0x00ffffffffffffff)) {
               flips |= flood ^m;
            };
            
            flood = 0;
            gen = m;
            pro = tstones & 0x007f7f7f7f7f7f7f;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 9) & pro);
            };
            if ((flood >> 9) & (astones & 0x007f7f7f7f7f7f7f)) {
               flips |= flood ^m;
            };

            flood = 0;
            gen = m;
            pro = tstones & 0x7f7f7f7f7f7f7f7f;
            while (gen)  {
                flood |= gen;
                gen = ((gen >> 1) & pro);
            };
            if ((flood >> 1) & (astones & 0x7f7f7f7f7f7f7f7f)) {
               flips |= flood ^ m;
            };

            flood = 0;
            gen = m;
            pro = tstones & 0x7f7f7f7f7f7f7f00;
            while (gen) {
                flood |= gen;
                gen = ((gen << 7) & pro);
            };
            if ((flood << 7) & (astones & 0x7f7f7f7f7f7f7f00)) {
               flips |= flood ^m;
            };

            flood = 0;
            gen = m;
            pro = tstones & 0xffffffffffffff00;
            while (gen) {
                flood |= gen;
                gen = ((gen << 8) & pro);
            }
            if ((flood << 8) & (astones & 0xffffffffffffff00)) {
               flips |= flood ^ m;
            };
            return flips;
}