.class public final synthetic Lr/g;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lr/i;

.field public final synthetic e:Lt/e;


# direct methods
.method public synthetic constructor <init>(Lr/i;Lt/e;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/g;->d:Lr/i;

    iput-object p2, p0, Lr/g;->e:Lt/e;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lr/g;->d:Lr/i;

    iget-object v1, p0, Lr/g;->e:Lt/e;

    invoke-static {v0, v1}, Lr/i;->f(Lr/i;Lt/e;)V

    return-void
.end method
