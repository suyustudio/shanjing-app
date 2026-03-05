.class public final Lh1/q;
.super Lh1/m1;
.source "SourceFile"


# instance fields
.field public final h:Lh1/m;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lh1/m<",
            "*>;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lh1/m;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/m<",
            "*>;)V"
        }
    .end annotation

    invoke-direct {p0}, Lh1/m1;-><init>()V

    iput-object p1, p0, Lh1/q;->h:Lh1/m;

    return-void
.end method


# virtual methods
.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ljava/lang/Throwable;

    invoke-virtual {p0, p1}, Lh1/q;->y(Ljava/lang/Throwable;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method

.method public y(Ljava/lang/Throwable;)V
    .locals 1

    iget-object p1, p0, Lh1/q;->h:Lh1/m;

    invoke-virtual {p0}, Lh1/q1;->z()Lh1/r1;

    move-result-object v0

    invoke-virtual {p1, v0}, Lh1/m;->v(Lh1/k1;)Ljava/lang/Throwable;

    move-result-object v0

    invoke-virtual {p1, v0}, Lh1/m;->E(Ljava/lang/Throwable;)V

    return-void
.end method
