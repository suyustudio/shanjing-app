.class final Lh1/t1;
.super Lh1/z1;
.source "SourceFile"


# instance fields
.field private final f:Ls0/d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ls0/d<",
            "Lq0/q;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Ls0/g;La1/p;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/g;",
            "La1/p<",
            "-",
            "Lh1/i0;",
            "-",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;+",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    const/4 v0, 0x0

    invoke-direct {p0, p1, v0}, Lh1/z1;-><init>(Ls0/g;Z)V

    invoke-static {p2, p0, p0}, Lt0/b;->a(La1/p;Ljava/lang/Object;Ls0/d;)Ls0/d;

    move-result-object p1

    iput-object p1, p0, Lh1/t1;->f:Ls0/d;

    return-void
.end method


# virtual methods
.method protected d0()V
    .locals 1

    iget-object v0, p0, Lh1/t1;->f:Ls0/d;

    invoke-static {v0, p0}, Lm1/a;->d(Ls0/d;Ls0/d;)V

    return-void
.end method
