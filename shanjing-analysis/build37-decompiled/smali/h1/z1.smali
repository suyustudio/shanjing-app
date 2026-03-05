.class Lh1/z1;
.super Lh1/a;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Lh1/a<",
        "Lq0/q;",
        ">;"
    }
.end annotation


# direct methods
.method public constructor <init>(Ls0/g;Z)V
    .locals 1

    const/4 v0, 0x1

    invoke-direct {p0, p1, v0, p2}, Lh1/a;-><init>(Ls0/g;ZZ)V

    return-void
.end method


# virtual methods
.method protected P(Ljava/lang/Throwable;)Z
    .locals 1

    invoke-virtual {p0}, Lh1/a;->getContext()Ls0/g;

    move-result-object v0

    invoke-static {v0, p1}, Lh1/h0;->a(Ls0/g;Ljava/lang/Throwable;)V

    const/4 p1, 0x1

    return p1
.end method
