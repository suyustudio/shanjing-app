.class public final Lh1/k1$a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lh1/k1;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "a"
.end annotation


# direct methods
.method public static synthetic a(Lh1/k1;Ljava/util/concurrent/CancellationException;ILjava/lang/Object;)V
    .locals 0

    if-nez p3, :cond_1

    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_0

    const/4 p1, 0x0

    :cond_0
    invoke-interface {p0, p1}, Lh1/k1;->n(Ljava/util/concurrent/CancellationException;)V

    return-void

    :cond_1
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "Super calls with default arguments not supported in this target, function: cancel"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static b(Lh1/k1;Ljava/lang/Object;La1/p;)Ljava/lang/Object;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<R:",
            "Ljava/lang/Object;",
            ">(",
            "Lh1/k1;",
            "TR;",
            "La1/p<",
            "-TR;-",
            "Ls0/g$b;",
            "+TR;>;)TR;"
        }
    .end annotation

    invoke-static {p0, p1, p2}, Ls0/g$b$a;->a(Ls0/g$b;Ljava/lang/Object;La1/p;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static c(Lh1/k1;Ls0/g$c;)Ls0/g$b;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<E::",
            "Ls0/g$b;",
            ">(",
            "Lh1/k1;",
            "Ls0/g$c<",
            "TE;>;)TE;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->b(Ls0/g$b;Ls0/g$c;)Ls0/g$b;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic d(Lh1/k1;ZZLa1/l;ILjava/lang/Object;)Lh1/t0;
    .locals 0

    if-nez p5, :cond_2

    and-int/lit8 p5, p4, 0x1

    if-eqz p5, :cond_0

    const/4 p1, 0x0

    :cond_0
    and-int/lit8 p4, p4, 0x2

    if-eqz p4, :cond_1

    const/4 p2, 0x1

    :cond_1
    invoke-interface {p0, p1, p2, p3}, Lh1/k1;->e(ZZLa1/l;)Lh1/t0;

    move-result-object p0

    return-object p0

    :cond_2
    new-instance p0, Ljava/lang/UnsupportedOperationException;

    const-string p1, "Super calls with default arguments not supported in this target, function: invokeOnCompletion"

    invoke-direct {p0, p1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static e(Lh1/k1;Ls0/g$c;)Ls0/g;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/k1;",
            "Ls0/g$c<",
            "*>;)",
            "Ls0/g;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->c(Ls0/g$b;Ls0/g$c;)Ls0/g;

    move-result-object p0

    return-object p0
.end method

.method public static f(Lh1/k1;Ls0/g;)Ls0/g;
    .locals 0

    invoke-static {p0, p1}, Ls0/g$b$a;->d(Ls0/g$b;Ls0/g;)Ls0/g;

    move-result-object p0

    return-object p0
.end method
