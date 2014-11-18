
for isent = 1:nsentences
    %%%% create the deep structure from simplied X-bar theory
    %deepstructure{isent} = GenerateSentence(r);
    %DisplayAllNodesWithLabels(deepstructure{isent},1);
    
    %%% from the deep structure, create the final surface structure, arrange the plurals etc
    %surface{isent} = DeepToSurface(deepstructure{isent}); 
    DisplaySentenceWithLabels(surface{isent},1,{});
    sfigure(31);clf;DisplayTree(surface{isent},1);
    
    %%% from the surface structure, substitute two items to get a shortened
    %%% version
    %shortened{isent} = Substitute(surface{isent});
    disp('********** SHORTENED VERSION **************');
    DisplaySentenceWithLabels(shortened{isent},1,{});
    sfigure(32);clf;DisplayTree(shortened{isent},1);
    
    outdir = 'outfigures';
    %%%% print the figures
    outfilefig=sprintf('%s\\sentence_%3d_long.png',outdir,isent);
    h=sfigure(31);
    print(h,'-dpng',outfilefig);
    outfilefig=sprintf('%s\\sentence_%3d_short.png',outdir,isent);
    h=sfigure(32);
    print(h,'-dpng',outfilefig);
        
end





    