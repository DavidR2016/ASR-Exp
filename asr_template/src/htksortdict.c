/*
    Author: Neil Kleynhans <ntkleynhans@csir.co.za>

    Code sorts a dictionary by word which makes HTK happy
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>


static int cmpstringp(const void *p1, const void *p2)
{
	return strcmp(* (char * const *) p1, * (char * const *) p2);
}

static void setWords(char *data, char *wlist[], long no)
{
	long n;
	char *cptr = data;

	for(n = 0L; n < no; n++)
	{
	    if(*cptr != '\\')
    		wlist[n] = cptr;
    	else
        	wlist[n] = ++cptr;

		while(!isspace(*(++cptr)));
		*cptr = '\0';
		while(*(++cptr) != '\n');
		*cptr++ = '\0';
	}
}

static void writeDict(char *data, char *wlist[], long no, FILE *fout)
{
	long n;
	char *cptr = data;

	for(n = 0L; n < no; n++)
	{
        switch(wlist[n][0])
        {
            case '\'':
            case '\"':
            	/*fprintf(fout, "\\%-39s ", wlist[n]);*/
                fprintf(fout, "\\%s\t", wlist[n]);
            break;
            default:
                /*fprintf(fout, "%-40s ", wlist[n]);*/
                fprintf(fout, "%s\t", wlist[n]);
            break;
        }

		cptr = wlist[n];
		/* Move to end of word */
		while(*(++cptr) != '\0');
		/* Move to begin of pron */
		while(isblank(*(++cptr)));

		fprintf(fout, "%s\n", cptr);
	}
}

static void fixwords(char *data, char *fixlist[], long fno)
{
	long m;
	char *fptr, *dptr;

	for(m=0; m<fno; m++)
	{
	    dptr = data;
	    while((fptr = strstr(dptr, fixlist[m])))
		{
		    *fptr = ' ';
		    while(!isspace(*(++fptr)))
				*fptr = ' ';
			dptr = fptr;
		}
    }
}

int main(int argc, char *argv[])
{
	FILE *fin, *fout;
	char buffer[1024], *data, *cptr, **wlist;
    /*char *fixlist[] = {"(2)", "(3)", "(4)", "(5)", "(6)", "(7)"};*/
	long end, no;

	if(argc < 3)
	{
		printf("Usage: htkdictsort indict outdict\n");
		return -1;
	}
	
	fin = fopen(argv[1],"r");
	if(!fin)
	{
		printf("Error : Unable to open %s\n", argv[1]);
		return -2;
	}

	fseek(fin, 0L, SEEK_END);
	end = ftell(fin);
	rewind(fin);

	data = malloc(((long)sizeof(char))*end+1024L);
	if(!data)
	{
		printf("Unable to load file into memory\n");
		return -3;
	}

	fread(data, sizeof(char), end, fin);
	data[end+1L] = EOF;
	fclose(fin);

	no = 0L;
	cptr = data;
	while(*cptr != EOF)
		if(*cptr++ == '\n')
			no++;

	wlist = calloc(no, sizeof(char *));
	/*fixwords(data, fixlist, 6L);*/
	setWords(data, wlist, no);

	/*for(end = 0L; end < no; end++)
		printf("%s\n", wlist[end]);*/

	qsort(&wlist[0], no, sizeof(char *), cmpstringp);

	/*for(end = 0L; end < no; end++)
		printf("%s\n", wlist[end]);*/

	fout = fopen(argv[2], "w");
	if(!fin)
	{
		printf("Error : Unable to open %s\n", argv[1]);
		return -2;
	}

	writeDict(data, wlist, no, fout);
 
	free(data);
	free(wlist);
	fclose(fout);
	return 0;
}
