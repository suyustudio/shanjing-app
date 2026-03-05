.class final synthetic Lh1/h;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static final a(Lh1/i0;Ls0/g;Lh1/k0;La1/p;)Lh1/k1;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/i0;",
            "Ls0/g;",
            "Lh1/k0;",
            "La1/p<",
            "-",
            "Lh1/i0;",
            "-",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;+",
            "Ljava/lang/Object;",
            ">;)",
            "Lh1/k1;"
        }
    .end annotation

    invoke-static {p0, p1}, Lh1/e0;->c(Lh1/i0;Ls0/g;)Ls0/g;

    move-result-object p0

    invoke-virtual {p2}, Lh1/k0;->c()Z

    move-result p1

    if-eqz p1, :cond_0

    new-instance p1, Lh1/t1;

    invoke-direct {p1, p0, p3}, Lh1/t1;-><init>(Ls0/g;La1/p;)V

    goto :goto_0

    :cond_0
    new-instance p1, Lh1/z1;

    const/4 v0, 0x1

    invoke-direct {p1, p0, v0}, Lh1/z1;-><init>(Ls0/g;Z)V

    :goto_0
    invoke-virtual {p1, p2, p1, p3}, Lh1/a;->v0(Lh1/k0;Ljava/lang/Object;La1/p;)V

    return-object p1
.end method

.method public static synthetic b(Lh1/i0;Ls0/g;Lh1/k0;La1/p;ILjava/lang/Object;)Lh1/k1;
    .locals 0

    and-int/lit8 p5, p4, 0x1

    if-eqz p5, :cond_0

    sget-object p1, Ls0/h;->d:Ls0/h;

    :cond_0
    and-int/lit8 p4, p4, 0x2

    if-eqz p4, :cond_1

    sget-object p2, Lh1/k0;->d:Lh1/k0;

    :cond_1
    invoke-static {p0, p1, p2, p3}, Lh1/g;->a(Lh1/i0;Ls0/g;Lh1/k0;La1/p;)Lh1/k1;

    move-result-object p0

    return-object p0
.end method
