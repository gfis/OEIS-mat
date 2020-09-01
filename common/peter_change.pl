#!perl
use strict; undef $/; 
print join("", map {
		my $block = $_;
		if ($block =~ m{\A\s*class\=\"docstring\"}) {
			$block =~ s{\<a\s+class\=\"source\-link\"\s+target\=\"_blank\"\s+href\=\"([^\"]+)\"\>([^\<]+)\<\/a\>(\r?\n\s*)}{}m;
			my $source_ref =                                                   $1;
			$block =~ s{\<a\s+class\=\"docstring-binding\"\s+id\=\"([^\"]+)\"\s+href\=\"\#([^\"]+)\"\>\<code\>([^\"]+)\<\/code\>\<\/a\>}
			           {\<a class\=\"docstring-binding\" id\=\"$1\" href\=\"$source_ref\"\>\<code\>$3\<\/code\>\<\/a\>}m;
		}
		$block
	} split(/(\<\/?section)/, <>));
__DATA__ 
        <section class="docstring">
            <div class="docstring-header"><a class="docstring-binding" id="Sequences.BernoulliIntList"
                    href="#Sequences.BernoulliIntList"><code>Sequences.BernoulliIntList</code></a> — <span
                    class="docstring-category">Function</span>.</div>
            <div>
                <div>
                    <p><strong></strong></p>
                    <p>Return a list of length len of the integer Bernoulli numbers <span>$b_{m}(n)$</span></p>
                </div>
            </div><a class="source-link" target="_blank"
                href="https://github.com/PeterLuschny/Sequences/blob/899db2d470d87b481c2344120317dd4fb9271893/src/Sequences.jl#L607-L610">source</a>
        </section>
        <section class="docstring">
            <div class="docstring-header"><a class="docstring-binding" id="Sequences.BernoulliList"
                    href="#Sequences.BernoulliList"><code>Sequences.BernoulliList</code></a> — <span
                    class="docstring-category">Function</span>.</div>
            <div>
                <div>
                    <p><strong></strong></p>
                    <p>Return a list of the first len Bernoulli numbers <span>$B_n$</span> (cf.
                        <code>[A027641/A027642]</code>).</p>
                    <pre><code class="language-none">julia&gt; BernoulliList(10)
[1, 1//2, 1//6, 0, -1//30, 0, 1//42, 0, -1//30, 0]</code></pre>
                </div>
            </div><a class="source-link" target="_blank"
                href="https://github.com/PeterLuschny/Sequences/blob/899db2d470d87b481c2344120317dd4fb9271893/src/Sequences.jl#L667-L674">source</a>
        </section>
 
         <section class="docstring">
              <div class="docstring-header">
                  <a class="docstring-binding" id="Fermat" href="#Fermat"><code>Fermat</code></a>
              </div>
              <div>
                  <div>
                      <p>abc</p>
                      <pre>fgh</pre>
                  </div>
              </div>
              <a class="source-link" target="_blank" href="#L654-L777">source</a>
          </section>
 
 
         <section class="docstring">
              <div class="docstring-header">
                  <a class="docstring-binding" id="Lucas" href="#Lucas"><code>Lucas</code></a>
              </div>
              <div>
                  <div>
                      <p>abc</p>
                      <pre>fgh</pre>
                  </div>
              </div>
              <a class="source-link" target="_blank" href="#L654-L888">source</a>
          </section>
 
diese Zeilen machen:

          <section class="docstring">
              <div class="docstring-header">
                  <a class="docstring-binding" id="Bernoulli" href="#L654-L661"><code>Bernoulli</code></a>
              </div>
              <div>
                  <div>
                      <p>abc</p>
                      <pre>fgh</pre>
                  </div>
              </div>
          </section>