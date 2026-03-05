.class final Lh1/e2;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/g$b;
.implements Ls0/g$c;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ls0/g$b;",
        "Ls0/g$c<",
        "Lh1/e2;",
        ">;"
    }
.end annotation


# static fields
.field public static final d:Lh1/e2;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lh1/e2;

    invoke-direct {v0}, Lh1/e2;-><init>()V

    sput-object v0, Lh1/e2;->d:Lh1/e2;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public fold(Ljava/lang/Object;La1/p;)Ljava/lang/Object;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<R:",
            "Ljava/lang/Object;",
            ">(TR;",
            "La1/p<",
            "-TR;-",
            "Ls0/g$b;",
            "+TR;>;)TR;"
        }
    .end annotation

    invoke-static {p0, p1, p2}, Ls0/g$b$a;->a(Ls0/g$b;Ljava/lang/Object;La1/p;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public get(Ls0/g$c;)Ls0/g$b;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<E::",
            "Ls0/g$b;",
            ">(",
            "Ls0/g$c<",
            "TE;>;)TE;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->b(Ls0/g$b;Ls0/g$c;)Ls0/g$b;

    move-result-object p1

    return-object p1
.end method

.method public getKey()Ls0/g$c;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ls0/g$c<",
            "*>;"
        }
    .end annotation

    return-object p0
.end method

.method public minusKey(Ls0/g$c;)Ls0/g;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/g$c<",
            "*>;)",
            "Ls0/g;"
        }
    .end annotation

    invoke-static {p0, p1}, Ls0/g$b$a;->c(Ls0/g$b;Ls0/g$c;)Ls0/g;

    move-result-object p1

    return-object p1
.end method

.method public plus(Ls0/g;)Ls0/g;
    .locals 0

    invoke-static {p0, p1}, Ls0/g$b$a;->d(Ls0/g$b;Ls0/g;)Ls0/g;

    move-result-object p1

    return-object p1
.end method
