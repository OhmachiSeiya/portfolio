#include <stdio.h>
#include <stdlib.h>

void loadText(int argc, const char **argv, unsigned char *t, int siz)
{
    FILE *fp;
    int i;
    if (argc < 2) {  // 引数が少ないのでエラー表示して終了.
        printf("usage>%s program-file\n", argv[0]);
        exit(1);
    }
    fp = fopen(argv[1], "rt"); // テキストモードでファイルを開く.
    if (fp == 0) {  // ファイルを開けなかった.
        printf("fopen error : %s\n", argv[1]);
        exit(1);
    }
    i = fread(t, 1, siz - 1, fp); // iは読み込んだバイト数.
    fclose(fp);
    t[i] = 0; // 終端マークを書いておく.
}

int main(int argc, const char **argv)
{
    unsigned char txt[10000]; // ソースコード.
    int i, pc, var[256];	// varは変数.
    loadText(argc, argv, txt, 10000);
    for (i = 0; i < 10; i++)
        var['0' + i] = i; // テクニック#1.
    for (pc = 0; txt[pc] != 0; pc++) {
        if (txt[pc] == '\n' || txt[pc] == '\r' || txt[pc] == ' ' || txt[pc] == '\t' || txt[pc] == ';')   // 空行など.
            continue;
        if (txt[pc + 1] == '=' && txt[pc + 3] == ';') { // 単純代入.
            var[txt[pc]] = var[txt[pc + 2]];
        } else if (txt[pc + 1] == '=' && txt[pc + 3] == '+' && txt[pc + 5] == ';') { // 加算.
            var[txt[pc]] = var[txt[pc + 2]] + var[txt[pc + 4]];
        } else if (txt[pc + 1] == '=' && txt[pc + 3] == '-' && txt[pc + 5] == ';') { // 減算.
            var[txt[pc]] = var[txt[pc + 2]] - var[txt[pc + 4]];
        } else if (txt[pc] == 'p' && txt[pc + 1] == 'r' && txt[pc + 5] == ' ' && txt[pc + 7] == ';') { // 最初の2文字しか調べてない(手抜き).
            printf("%d\n", var[txt[pc + 6]]);
        } else
            goto err;
        while (txt[pc] != ';')
            pc++;
    }
    exit(0);
err:
    printf("syntax error : %.10s\n", &txt[pc]);
    exit(1);
}
